from random import sample
from flask_cors import CORS


from flask import Blueprint, request, current_app, abort


bp = Blueprint("words", __name__, url_prefix="/words")
CORS(bp)


@bp.route("/random")
def random():
    nums_param = int(request.args.get("n", 5))
    # Validate the nums_param
    if not 0 < nums_param <= 100:
        return abort(400)
    dictionary_words = current_app.config.get("words")
    words = sample(dictionary_words, nums_param)
    joined = " ".join(words)
    lower = request.args.get("lower")
    if lower:
        joined = joined.lower()
    return joined


@bp.route("/generate")
def words():
    nums_param = int(request.args.get("n", 5))
    source_param = request.args.get("source", "shakespeare")
    source = current_app.config.get("sources").get(source_param)
    words = source.generate(nums_param)
    return " ".join(words)
