import re
import requests

url_pattern = re.compile(r"https?:\/\/.*[\r\n]*")

# [TODO] Split the lines by '.'


def sanitize(tweet) -> str:
    if "http" in tweet:
        tweet = re.sub(url_pattern, "", tweet)
    return (
        tweet.strip()
        .replace("\n", "")
        .replace("&amp", "")
        .replace("“", '"')
        .replace("”", '"')
        .replace("’", "'")
    )


def fetch_tweets():
    url = "http://www.trumptwitterarchive.com/data/realdonaldtrump/2018.json"
    return requests.get(url).json()


def parse_tweets(tweets):
    tweets = (
        sanitize(tweet["text"]) for tweet in tweets if not tweet["is_retweet"]
    )
    return filter(None, tweets)


if __name__ == "__main__":
    with open("sources/trump.txt", "w+") as outfile:
        outfile.write("\n".join(parse_tweets(fetch_tweets())))
