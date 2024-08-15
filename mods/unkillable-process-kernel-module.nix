{ stdenv
, lib
, fetchFromGitHub
, kernel
, kmod
}: let 
# from: https://ortiz.sh/linux/2020/07/05/UNKILLABLE.html
srcCode = ''
  #include <linux/init.h>
  #include <linux/module.h>
  #include <linux/kernel.h>
  #include <linux/types.h>
  #include <linux/proc_fs.h>
  #include <linux/sched.h>
  #include <linux/sched/signal.h>
  #include <linux/pid.h>

  MODULE_LICENSE("GPL");

  void unkillable_exit(void);
  int unkillable_init(void);

  /* device access functions */
  ssize_t unkillable_write(struct file *filp, const char *buf, size_t count, loff_t *f_pos);
  ssize_t unkillable_read(struct file *filp, char *buf, size_t count, loff_t *f_pos);
  int unkillable_open(struct inode *inode, struct file *filp);
  int unkillable_release(struct inode *inode, struct file *filp);
  struct file_operations unkillable_fops = {
    .read = unkillable_read,
    .write = unkillable_write,
    .open = unkillable_open,
    .release = unkillable_release
  };

  /* Declaration of the init and exit functions */
  module_init(unkillable_init);
  module_exit(unkillable_exit);

  int unkillable_major = 117;

  int unkillable_init(void) 
  {
    if (register_chrdev(unkillable_major, "unkillable", &unkillable_fops) < 0 ) {
      printk("Unkillable: cannot obtain major number %d\n", unkillable_major);
      return 1;
    }

    printk("Inserting unkillable module\n"); 
    return 0;
  }

  void unkillable_exit(void) 
  {
    unregister_chrdev(unkillable_major, "unkillable");
    printk("Removing unkillable module\n");
  }

  int unkillable_open(struct inode *inode, struct file *filp) 
  {
    return 0;
  }

  int unkillable_release(struct inode *inode, struct file *filp) 
  {
    return 0;
  }

  ssize_t unkillable_read(struct file *filp, char *buf, size_t count, loff_t *f_pos) 
  { 
    struct pid *pid_struct;
    struct task_struct *p;
    
    /* interpret count to read as target pid */
    printk("Unkillable: Got pid %d", (int) count);

    /* get the pid struct */
    pid_struct = find_get_pid((int) count);

    /* get the task_struct from the pid */
    p = pid_task(pid_struct, PIDTYPE_PID);

    /* add the flag */
    p->signal->flags = p->signal->flags | SIGNAL_UNKILLABLE;
    printk("Unkillable: pid %d marked as unkillable\n", (int) count);
    
    if (*f_pos == 0) { 
      *f_pos+=1; 
      return 1; 
    } else { 
      return 0; 
    }
  }

  ssize_t unkillable_write(struct file *filp, const char *buf, size_t count, loff_t *f_pos) 
  {
    return 0;
  }
'';
srcMakeFile = ''
obj-m := unkillable.o

all:
${"\t"}$(MAKE) -C $(KERNEL_DIR) M=$(PWD) modules

unkillable.o:
${"\t"}$(CC) unkillable.c -o unkillable.o

install:
${"\t"}$(MAKE) -C $(KERNEL_DIR) M=$(PWD) modules_install
'';
srcMakeFileFull = ''
  obj-m += unkillable.o

  all:
    make -C /lib/modules/$KERNELRELEASE/build M=$(PWD) modules

  clean:
    make -C /lib/modules/$KERNELRELEASE/build M=$(PWD) clean

  install:
    sudo insmod unkillable.ko

  uninstall:
    sudo rmmod unkillable

  mknod:
    sudo mknod /dev/unkillable c 117 0
    sudo chmod 666 /dev/unkillable
'';

in stdenv.mkDerivation rec {
  name = "unkillableKernelModule-${version}-${kernel.version}";
  version = "0.1";

  src = stdenv.mkDerivation {
    name = "unkillableKernelModule-source";
    dontUnpack = true;
    dontPatch = true;
    dontConfigure = true;
    buildPhase = ''
      mkdir -p $out
      echo '${srcCode}' > $out/unkillable.c
      echo '${srcMakeFile}' > $out/Makefile
    '';
  };

  #preUnpack = ''
  # mkdir -p source/linux/unkillableKernelModule
  # '';
  #sourceRoot = "source/linux/unkillableKernelModule";
  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
  ];

  meta = with lib; {
    description = "A kernel module that makes a char-device /dev/unkillable, from which you can read($your_pid) from, which then makes your process unkillable. code from: https://ortiz.sh/linux/2020/07/05/UNKILLABLE.html";
    homepage = "https://ortiz.sh/linux/2020/07/05/UNKILLABLE.html";
    license = licenses.gpl2;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
