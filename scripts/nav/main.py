
import shlex
from pathlib import Path
from os import path
import os

DB_FILE = "/home/me/work/config/nav/db"


def main():
    pwd = Path(os.getcwd())
    db_matches = get_db_matches(pwd)
    folder_matches = get_folder_matches(pwd)

    print(my_resolve("~/work/config"))
    print("db:", db_matches)
    print("folder:", folder_matches)


def get_db_matches(directory):
    matches = []
    with open(DB_FILE, "r") as file:
        for line in file.readlines():
            tmp = shlex.split(line)
            try:
                dir_in = tmp[0]
                shortcut = tmp[1]
                dest = tmp[2]
            except:
                continue

            if dir_in == "*":
                matches.append((shortcut, dest))
            if dir_in == "~":
                #if directory == Path.home():
                matches.append((shortcut, dest))

    return matches

def get_folder_matches(directory):
    matches = []
    ls = os.listdir(directory)

    return matches

def my_resolve(path):
    if str(path)[0] == "~":
        path_as_list = list(str(path))
        path_as_list.pop(0)
        print("path_as_list:", path_as_list)
        return Path(str(Path.home()) + "".join(path_as_list))

    return path.resolve()


if __name__ == "__main__":
    main()

