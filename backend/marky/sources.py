from dataclasses import dataclass
import markovify


@dataclass
class FileSource:

    """
    Generates random sentences from a file
    """

    name: str
    fname: str

    def __post_init__(self):
        with open(self.fname) as f:
            self.text = markovify.NewlineText(f.read())

    def generate(self, n=5):
        for i in range(n):
            yield self.text.make_short_sentence(max_chars=120)
