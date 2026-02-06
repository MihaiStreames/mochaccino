import re
import sys
from urllib.parse import parse_qs, urlencode, urlparse, urlunparse

import pyperclip


def clean_link(
    link,
    youtube_shorten_enabled=False,
    fix_twitter_enabled=False,
    walmart_shorten_enabled=False,
    amazon_tracking_id=None,
):
    """
    Clean tracking parameters from a URL while preserving essential parameters.

    Args:
        link: The URL to clean
        youtube_shorten_enabled: Convert YouTube links to youtu.be format
        fix_twitter_enabled: Convert Twitter/X links to fxtwitter.com
        walmart_shorten_enabled: Shorten Walmart product links
        amazon_tracking_id: Optional Amazon affiliate tag to add

    Returns:
        Cleaned URL as a string
    """
    try:
        # Try to extract URL from text if needed
        if not link.startswith(("http://", "https://")):
            url_match = re.search(r"https?://\S+", link)
            if url_match:
                link = url_match.group(0)
            else:
                raise ValueError("No valid URL found in the string")

        old_url = urlparse(link)
        old_params = parse_qs(old_url.query)

        # Fix various link shorteners
        if old_url.netloc == "l.facebook.com" and "u" in old_params:
            # Facebook shared links
            facebook_link = old_params["u"][0]
            old_url = urlparse(facebook_link)
            old_params = parse_qs(old_url.query)

        elif old_url.netloc == "href.li":
            # href.li links
            href_link = link.split("?", 1)[1] if "?" in link else link
            old_url = urlparse(href_link)
            old_params = parse_qs(old_url.query)

        elif (
            old_url.netloc == "www.google.com"
            and old_url.path == "/url"
            and "url" in old_params
        ):
            # Google Search redirect links
            old_url = urlparse(old_params["url"][0])
            old_params = parse_qs(old_url.query)

        # Start with clean URL (origin + pathname only)
        new_params = {}

        # Preserve 'q' parameter (search queries)
        if "q" in old_params:
            new_params["q"] = old_params["q"]

        # Google Play links
        if old_url.netloc == "play.google.com" and "id" in old_params:
            new_params["id"] = old_params["id"]

        # Macy's links
        if old_url.netloc == "www.macys.com" and "ID" in old_params:
            new_params["ID"] = old_params["ID"]

        # YouTube links
        if old_url.netloc.endswith("youtube.com"):
            if "v" in old_params:
                if youtube_shorten_enabled:
                    # Extract video ID and create short link
                    video_id_match = re.search(
                        r"(?:youtu\.be/|embed/|shorts/|\?v=|&v=)([^#&?]*)", link
                    )
                    if video_id_match:
                        video_id = video_id_match.group(1)
                        new_url = urlparse(f"https://youtu.be/{video_id}")
                        new_params = {}
                        # Add timestamp if present
                        if "t" in old_params:
                            new_params["t"] = old_params["t"]

                        query_string = (
                            urlencode(new_params, doseq=True) if new_params else ""
                        )
                        result = urlunparse(
                            (
                                new_url.scheme,
                                new_url.netloc,
                                new_url.path,
                                "",
                                query_string,
                                "",
                            )
                        )
                        return result
                else:
                    new_params["v"] = old_params["v"]

            # Preserve timestamp
            if "t" in old_params:
                new_params["t"] = old_params["t"]

            # Preserve playlist ID
            if "playlist" in old_url.path and "list" in old_params:
                new_params["list"] = old_params["list"]

        # Shortened YouTube links
        elif old_url.netloc == "youtu.be" and "t" in old_params:
            new_params["t"] = old_params["t"]

        # Facebook story links
        if old_url.netloc == "www.facebook.com" and "story.php" in old_url.path:
            if "story_fbid" in old_params:
                new_params["story_fbid"] = old_params["story_fbid"]
            if "id" in old_params:
                new_params["id"] = old_params["id"]

        # Amazon links
        new_path = old_url.path
        new_netloc = old_url.netloc

        if "amazon" in old_url.netloc and any(
            x in old_url.path for x in ["/dp/", "/d/", "/product/"]
        ):
            # Remove www subdomain
            new_netloc = old_url.netloc.replace("www.", "")
            # Extract product ID
            product_match = re.search(r"(?:/dp/|/product/|/d/)(\w+)", old_url.path)
            if product_match:
                new_path = f"/dp/{product_match.group(1)}"

            # Add affiliate tag if provided
            if amazon_tracking_id:
                new_params["tag"] = [amazon_tracking_id]

        # Lenovo store links
        if old_url.netloc == "www.lenovo.com" and "bundleId" in old_params:
            new_params["bundleId"] = old_params["bundleId"]

        # Best Buy links
        if old_url.netloc == "www.bestbuy.com" and ".p" in old_url.path:
            product_match = re.search(r"/(\d+)\.p", old_url.path)
            if product_match:
                new_path = f"/site/{product_match.group(1)}.p"

        # Xiaohongshu links
        if old_url.netloc == "www.xiaohongshu.com" and "xsec_token" in old_params:
            new_params["xsec_token"] = old_params["xsec_token"]

        # Apple Weather links
        if old_url.netloc == "weatherkit.apple.com":
            for param in ["lang", "party", "ids"]:
                if param in old_params:
                    new_params[param] = old_params[param]

        # BusinessWire tracking links
        if old_url.netloc == "cts.businesswire.com" and "url" in old_params:
            return clean_link(
                old_params["url"][0],
                youtube_shorten_enabled,
                fix_twitter_enabled,
                walmart_shorten_enabled,
                amazon_tracking_id,
            )

        # Webtoon links
        if old_url.netloc == "www.webtoons.com":
            if "title_no" in old_params:
                new_params["title_no"] = old_params["title_no"]
            if "episode_no" in old_params:
                new_params["episode_no"] = old_params["episode_no"]

        # Twitter/X to FixTwitter
        if fix_twitter_enabled and old_url.netloc in ("twitter.com", "x.com"):
            new_netloc = "fxtwitter.com"

        # Walmart links
        if (
            walmart_shorten_enabled
            and old_url.netloc == "www.walmart.com"
            and "/ip/" in old_url.path
        ):
            product_match = re.search(r"/ip/.*/(\d+)", old_url.path)
            if product_match:
                new_path = f"/ip/{product_match.group(1)}"

        # Build the clean URL
        query_string = urlencode(new_params, doseq=True) if new_params else ""

        result = urlunparse(
            (old_url.scheme, new_netloc, new_path, "", query_string, "")
        )

        return result

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return link


def main():
    """Main CLI entry point"""
    if len(sys.argv) < 2:
        print("Usage: python link_cleaner.py <url>", file=sys.stderr)
        print(
            "Example: python link_cleaner.py 'https://www.amazon.com/dp/B08N5WRWNW?tag=tracking123'",
            file=sys.stderr,
        )
        sys.exit(1)

    link = sys.argv[1]
    cleaned = clean_link(link)

    # Output only the cleaned link
    print(cleaned)

    # Copy to clipboard
    pyperclip.copy(cleaned)
    return True


if __name__ == "__main__":
    main()
