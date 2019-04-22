import urllib.request
from urllib.parse import urljoin


url = urljoin(
    "https://ocw.mit.edu/ans7870/6/6.006/s08/lecturenotes/files/",
    "t8.shakespeare.txt",
)


def entrace_scene(line):
    return line.startswith("Enter") or line.startswith("Re-enter")


def end_scene(line):
    return line.startswith("Exit") or line.startswith("THE END")


def parse_lines(f):
    for line in f:
        decoded = line.decode().strip()
        if decoded.startswith("<<THIS ELECTRONIC"):
            for i in range(7):
                next(f)
        else:
            if decoded:
                if all((letter.isupper() for letter in "".join(decoded))):
                    continue
                elif decoded.startswith("End of this Etext"):
                    return
                elif decoded == "by William Shakespeare":
                    continue
                elif decoded.isdigit():
                    continue
                elif entrace_scene(decoded):
                    continue
                elif end_scene(decoded):
                    continue
                else:
                    yield decoded


if __name__ == "__main__":
    corpus = urllib.request.urlopen(url)
    lines = corpus.read().splitlines()

    content = iter(lines[253:-20])

    parsed = list(parse_lines(content))
    with open("sources/shakespearev2.txt", "w+") as f:
        f.write("\n".join(parsed))
