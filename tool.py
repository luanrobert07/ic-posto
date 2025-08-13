# Change this to the project's folder
ROOT_DIR = 'posto'

import os


class ProjectTracker:
    def __init__(self, root_directory):
        self.root_directory = root_directory

        self.flutterStats = self._createEmptyStats()
        self.cloudStats = self._createEmptyStats()

    def run(self):
        self.resetVariables()
        self.sweepFlutterProject()
        self.sweepCloudFunctionsProject()
        self.printProjectParameters()

    def resetVariables(self):
        self.flutterStats = self._createEmptyStats()
        self.cloudStats = self._createEmptyStats()

    def sweepFlutterProject(self):
        for path, subdirs, files in os.walk(self.root_directory):
            for name in files:
                if name.endswith('.g.dart'):
                    continue
                if name.endswith('.freezed.dart'):
                    continue
                if "l10n" in path.split(os.sep):
                    continue

                self.readFile(os.path.join(path, name), self.flutterStats)

    def sweepCloudFunctionsProject(self):
        for path, subdirs, files in os.walk('./cloud_functions/functions'):
            if 'node_modules' in path.split(os.sep):
                continue

            for name in files:
                if not name.endswith('.js'):
                    continue

                self.readFile(os.path.join(path, name), self.cloudStats)

    def readFile(self, fileName, stats):
        with open(fileName, 'r', encoding="utf8") as file:
            fileContent = file.read()
            self.countFileContent(fileContent, stats)

    @staticmethod
    def countFileContent(fileContent, stats):
        stats["files"] += 1

        fileLines = fileContent.strip().split('\n')
        totalLines = len(fileLines)
        stats["lines"] += totalLines

        for line in fileLines:
            if not line.strip():
                continue
            stats["chars"] += len(line.strip())
            stats["codeLines"] += 1

        stats["biggest"] = max(stats["biggest"], totalLines)
        stats["smallest"] = min(stats["smallest"], totalLines)

    @staticmethod
    def print_stats(title, stats):
        print(f'--- {title} ---')
        print(f'Total lines: {stats["lines"]}')
        print(f'Total logical lines: {stats["codeLines"]}')
        print(f'Files: {stats["files"]}')
        print(f'Biggest file: {stats["biggest"]}')
        print(f'Smallest file: {stats["smallest"]}')
        print(f'Characters: {stats["chars"]}')
        if stats["files"] > 0:
            print(f'Avg. lines per file: {stats["lines"] / stats["files"]:.2f}')
            print(f'Avg. chars per file: {stats["chars"] / stats["files"]:.2f}')
        print()

    def printProjectParameters(self):
        self.print_stats("Flutter Project", self.flutterStats)
        self.print_stats("Cloud Functions", self.cloudStats)

        combined = {
            "lines": self.flutterStats["lines"] + self.cloudStats["lines"],
            "codeLines": self.flutterStats["codeLines"] + self.cloudStats["codeLines"],
            "chars": self.flutterStats["chars"] + self.cloudStats["chars"],
            "files": self.flutterStats["files"] + self.cloudStats["files"],
            "biggest": max(self.flutterStats["biggest"], self.cloudStats["biggest"]),
            "smallest": min(self.flutterStats["smallest"], self.cloudStats["smallest"]),
        }

        self.print_stats("Combined Total", combined)

    @staticmethod
    def _createEmptyStats():
        return {
            "lines": 0,
            "codeLines": 0,
            "chars": 0,
            "files": 0,
            "biggest": 0,
            "smallest": float('inf')
        }


def main():
    while True:
        print()
        print('[1] - Show metrics for project files')
        print('[2] - Build release apk')
        print('[3] - Build and install release apk')
        print('[4] - Install last release apk built')

        choice = input()
        print()

        match choice:
            case '1':
                show_metrics()
            case '2':
                if not build_release():
                    print()
                    print('One or more errors have occured!')
            case '3':
                if not build_and_install_release():
                    print()
                    print('One or more errors have occured!')
            case '4':
                if not installRelease():
                    print()
                    print('One or more errors have occured!')
            case _:
                print("Invalid option")

        print()


def build_and_install_release():
    if cleanProject():
        return False

    if buildRelease():
        return False

    if installRelease():
        return False

    return True


def build_release():
    if cleanProject():
        return False

    if buildRelease():
        return False

    if openReleaseFolder():
        return False

    return True


def cleanProject():
    return os.system(f'cd {ROOT_DIR} && flutter clean')


def buildRelease():
    return os.system(f'cd {ROOT_DIR} && flutter build apk --target-platform android-arm64')


def installRelease():
    return os.system(f'cd {ROOT_DIR} && adb install "./build/app/outputs/flutter-apk/app-release.apk"')


def openReleaseFolder():
    path = f'{os.getcwd()}\\{ROOT_DIR}\\build\\app\\outputs\\flutter-apk'
    return os.system(f'explorer {path}')


def show_metrics():
    root_dir = f'./{ROOT_DIR}/lib'
    project_tracker = ProjectTracker(root_dir)
    project_tracker.run()


if __name__ == '__main__':
    main()
