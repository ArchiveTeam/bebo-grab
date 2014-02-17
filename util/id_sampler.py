'''This script samples profile IDs to find the percentage of 200 OK and
404 Not found'''
from __future__ import print_function
import random
import urllib2

URL = 'http://archive.bebo.com/Profile.jsp?MemberId={0}'


def main(start=1, end=11100000000):
    random.seed(42)

    ok = 0
    bad = 0

    for profile_id in random.sample(xrange(start, end + 1), 1000):
        try:
            url = URL.format(profile_id)
            urllib2.urlopen(url)
        except urllib2.URLError as error:
            print(error)
            bad += 1
        else:
            ok += 1

        ratio = float(ok) / bad
        print('ID=', profile_id, 'OK=', ok, 'Bad=', bad, 'Ratio=', ratio)

if __name__ == '__main__':
    main()
