from __future__ import print_function


def main():
    start = 1
    end = 11100000000
    size = 10000

    for num in xrange(start, end + 1, size):
        print('{0}:{1}'.format(num, num + size - 1))


if __name__ == '__main__':
    main()
