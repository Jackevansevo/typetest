import os

from marky.sources import FileSource
from flask import Flask
import glob


def create_app(test_config=None):

    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(SECRET_KEY="dev")

    if test_config is None:
        # load the instance config, if it exists, when not testing
        app.config.from_pyfile("config.py", silent=True)
    else:
        # load the test config if passed in
        app.config.from_mapping(test_config)

    # ensure the instance folder exists
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    from . import words

    with open("/usr/share/dict/words") as f:
        dictionary_words = f.read().splitlines()
        app.config["words"] = {
            word for word in dictionary_words if "'" not in word
        }

    source_files = glob.glob("sources/*.txt")
    sources = {}
    for fname in source_files:
        name, _ = os.path.splitext(os.path.basename(fname))
        sources[name] = FileSource(name, fname)
        app.config["sources"] = sources

    app.register_blueprint(words.bp)

    # a simple page that says hello
    @app.route("/")
    def health():
        return "ok"

    return app
