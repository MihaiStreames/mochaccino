#!/usr/bin/env python3

import re
import sys
from urllib.parse import parse_qs
from urllib.parse import urlencode
from urllib.parse import urlparse
from urllib.parse import urlunparse

import pyperclip


def _clean_link(link, youtube_shorten_enabled=False, fix_twitter_enabled=False, walmart_shorten_enabled=False, amazon_tracking_id=None):
    try:
        if not link.startswith(("http://", "https://")):
            url_match = re.search(r"https?://\S+", link)
            if url_match:
                link = url_match.group(0)
            else:
                msg = "No valid URL found in the string"
                raise ValueError(msg)

        old_url = urlparse(link)
        old_params = parse_qs(old_url.query)

        if old_url.netloc == "l.facebook.com" and "u" in old_params:
            facebook_link = old_params["u"][0]
            old_url = urlparse(facebook_link)
            old_params = parse_qs(old_url.query)

        elif old_url.netloc == "href.li":
            href_link = link.split("?", 1)[1] if "?" in link else link
            old_url = urlparse(href_link)
            old_params = parse_qs(old_url.query)

        elif old_url.netloc == "www.google.com" and old_url.path == "/url" and "url" in old_params:
            old_url = urlparse(old_params["url"][0])
            old_params = parse_qs(old_url.query)

        new_params = {}

        if "q" in old_params:
            new_params["q"] = old_params["q"]

        if old_url.netloc == "play.google.com" and "id" in old_params:
            new_params["id"] = old_params["id"]

        if old_url.netloc == "www.macys.com" and "ID" in old_params:
            new_params["ID"] = old_params["ID"]

        if old_url.netloc.endswith("youtube.com"):
            if "v" in old_params:
                if youtube_shorten_enabled:
                    video_id_match = re.search(r"(?:youtu\.be/|embed/|shorts/|\?v=|&v=)([^#&?]*)", link)
                    if video_id_match:
                        video_id = video_id_match.group(1)
                        new_url = urlparse(f"https://youtu.be/{video_id}")
                        new_params = {}

                        if "t" in old_params:
                            new_params["t"] = old_params["t"]

                        query_string = urlencode(new_params, doseq=True) if new_params else ""
                        return urlunparse((new_url.scheme, new_url.netloc, new_url.path, "", query_string, ""))
                else:
                    new_params["v"] = old_params["v"]

            if "t" in old_params:
                new_params["t"] = old_params["t"]

            if "playlist" in old_url.path and "list" in old_params:
                new_params["list"] = old_params["list"]

        elif old_url.netloc == "youtu.be" and "t" in old_params:
            new_params["t"] = old_params["t"]

        if old_url.netloc == "www.facebook.com" and "story.php" in old_url.path:
            if "story_fbid" in old_params:
                new_params["story_fbid"] = old_params["story_fbid"]
            if "id" in old_params:
                new_params["id"] = old_params["id"]

        new_path = old_url.path
        new_netloc = old_url.netloc

        if "amazon" in old_url.netloc and any(x in old_url.path for x in ["/dp/", "/d/", "/product/"]):
            new_netloc = old_url.netloc.replace("www.", "")
            product_match = re.search(r"(?:/dp/|/product/|/d/)(\w+)", old_url.path)
            if product_match:
                new_path = f"/dp/{product_match.group(1)}"
            if amazon_tracking_id:
                new_params["tag"] = [amazon_tracking_id]

        if old_url.netloc == "www.lenovo.com" and "bundleId" in old_params:
            new_params["bundleId"] = old_params["bundleId"]

        if old_url.netloc == "www.bestbuy.com" and ".p" in old_url.path:
            product_match = re.search(r"/(\d+)\.p", old_url.path)
            if product_match:
                new_path = f"/site/{product_match.group(1)}.p"

        if old_url.netloc == "www.xiaohongshu.com" and "xsec_token" in old_params:
            new_params["xsec_token"] = old_params["xsec_token"]

        if old_url.netloc == "weatherkit.apple.com":
            for param in ["lang", "party", "ids"]:
                if param in old_params:
                    new_params[param] = old_params[param]

        if old_url.netloc == "cts.businesswire.com" and "url" in old_params:
            return _clean_link(old_params["url"][0], youtube_shorten_enabled, fix_twitter_enabled, walmart_shorten_enabled, amazon_tracking_id)

        if old_url.netloc == "www.webtoons.com":
            if "title_no" in old_params:
                new_params["title_no"] = old_params["title_no"]
            if "episode_no" in old_params:
                new_params["episode_no"] = old_params["episode_no"]

        if fix_twitter_enabled and old_url.netloc in ("twitter.com", "x.com"):
            new_netloc = "fxtwitter.com"

        if walmart_shorten_enabled and old_url.netloc == "www.walmart.com" and "/ip/" in old_url.path:
            product_match = re.search(r"/ip/.*/(\d+)", old_url.path)
            if product_match:
                new_path = f"/ip/{product_match.group(1)}"

        query_string = urlencode(new_params, doseq=True) if new_params else ""

        return urlunparse((old_url.scheme, new_netloc, new_path, "", query_string, ""))

    except Exception:
        return link


def main() -> bool:
    if len(sys.argv) < 2:
        print("Usage: python link_cleaner.py <url>", file=sys.stderr)
        print("Example: python link_cleaner.py 'https://www.amazon.com/dp/B08N5WRWNW?tag=tracking123'", file=sys.stderr)
        sys.exit(1)

    link = sys.argv[1]
    cleaned = _clean_link(link)

    # Output only the cleaned link
    print(cleaned)

    # Copy to clipboard
    pyperclip.copy(cleaned)
    return True


if __name__ == "__main__":
    main()
