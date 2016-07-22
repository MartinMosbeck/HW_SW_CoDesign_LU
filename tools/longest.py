import sys

def longest_common_substring(s1, s2):
    print("InFUNC!")
    m = [[0] * (1 + len(s2)) for i in range(1 + len(s1))]
    longest, x_longest = 0, 0
    for x in range(1, 1 + len(s1)):
        print(str(x))
        sys.stdout.flush()
        for y in range(1, 1 + len(s2)):
            if s1[x - 1] == s2[y - 1]:
                m[x][y] = m[x - 1][y - 1] + 1
                if m[x][y] > longest:
                    longest = m[x][y]
                    x_longest = x
            else:
                m[x][y] = 0
    return s1[x_longest - longest: x_longest]

if __name__ == '__main__':
    f1=open("dump2.txt","r")
    f2=open("ethtst.txt","r")
    s1=f1.read()
    s2=f2.read()
    #s1="ABBABABABAAAAAAABBBB"
    #s2="AAACBCBCBIQ"
    print("beforeFunc")
    common = longest_common_substring(s1,s2)
    print("\n"+common)
