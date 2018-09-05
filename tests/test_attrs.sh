#!/bin/bash
set -eu

echo "=== Attr tests ==="
rm -rf blocks
tests/test.py << TEST
    lfs_format(&lfs, &cfg) => 0;

    lfs_mount(&lfs, &cfg) => 0;
    lfs_mkdir(&lfs, "hello") => 0;
    lfs_file_open(&lfs, &file[0], "hello/hello",
            LFS_O_WRONLY | LFS_O_CREAT) => 0;
    lfs_file_write(&lfs, &file[0], "hello", strlen("hello"))
            => strlen("hello");
    lfs_file_close(&lfs, &file[0]);
    lfs_unmount(&lfs) => 0;
TEST

echo "--- Set/get attribute ---"
tests/test.py << TEST
    lfs_mount(&lfs, &cfg) => 0;
    lfs_setattr(&lfs, "hello", 'A', "aaaa",   4) => 0;
    lfs_setattr(&lfs, "hello", 'B', "bbbbbb", 6) => 0;
    lfs_setattr(&lfs, "hello", 'C', "ccccc",  5) => 0;
    lfs_getattr(&lfs, "hello", 'A', buffer,    4) => 4;
    lfs_getattr(&lfs, "hello", 'B', buffer+4,  6) => 6;
    lfs_getattr(&lfs, "hello", 'C', buffer+10, 5) => 5;
    memcmp(buffer,    "aaaa",   4) => 0;
    memcmp(buffer+4,  "bbbbbb", 6) => 0;
    memcmp(buffer+10, "ccccc",  5) => 0;

    lfs_setattr(&lfs, "hello", 'B', "", 0) => 0;
    lfs_getattr(&lfs, "hello", 'A', buffer,    4) => 4;
    lfs_getattr(&lfs, "hello", 'B', buffer+4,  6) => 0;
    lfs_getattr(&lfs, "hello", 'C', buffer+10, 5) => 5;
    memcmp(buffer,    "aaaa",         4) => 0;
    memcmp(buffer+4,  "\0\0\0\0\0\0", 6) => 0;
    memcmp(buffer+10, "ccccc",        5) => 0;

    lfs_setattr(&lfs, "hello", 'B', "dddddd", 6) => 0;
    lfs_getattr(&lfs, "hello", 'A', buffer,    4) => 4;
    lfs_getattr(&lfs, "hello", 'B', buffer+4,  6) => 6;
    lfs_getattr(&lfs, "hello", 'C', buffer+10, 5) => 5;
    memcmp(buffer,    "aaaa",   4) => 0;
    memcmp(buffer+4,  "dddddd", 6) => 0;
    memcmp(buffer+10, "ccccc",  5) => 0;

    lfs_setattr(&lfs, "hello", 'B', "eee", 3) => 0;
    lfs_getattr(&lfs, "hello", 'A', buffer,    4) => 4;
    lfs_getattr(&lfs, "hello", 'B', buffer+4,  6) => 3;
    lfs_getattr(&lfs, "hello", 'C', buffer+10, 5) => 5;
    memcmp(buffer,    "aaaa",      4) => 0;
    memcmp(buffer+4,  "eee\0\0\0", 6) => 0;
    memcmp(buffer+10, "ccccc",     5) => 0;

    lfs_setattr(&lfs, "hello", 'A', buffer, LFS_ATTR_MAX+1) => LFS_ERR_NOSPC;
    lfs_setattr(&lfs, "hello", 'B', "fffffffff", 9) => 0;
    lfs_getattr(&lfs, "hello", 'A', buffer,    4) => 4;
    lfs_getattr(&lfs, "hello", 'B', buffer+4,  6) => 9;
    lfs_getattr(&lfs, "hello", 'C', buffer+10, 5) => 5;

    lfs_unmount(&lfs) => 0;
TEST
tests/test.py << TEST
    lfs_mount(&lfs, &cfg) => 0;
    lfs_getattr(&lfs, "hello", 'A', buffer,    4) => 4;
    lfs_getattr(&lfs, "hello", 'B', buffer+4,  9) => 9;
    lfs_getattr(&lfs, "hello", 'C', buffer+13, 5) => 5;
    memcmp(buffer,    "aaaa",      4) => 0;
    memcmp(buffer+4,  "fffffffff", 9) => 0;
    memcmp(buffer+13, "ccccc",     5) => 0;

    lfs_file_open(&lfs, &file[0], "hello/hello", LFS_O_RDONLY) => 0;
    lfs_file_read(&lfs, &file[0], buffer, sizeof(buffer)) => strlen("hello");
    memcmp(buffer, "hello", strlen("hello")) => 0;
    lfs_file_close(&lfs, &file[0]);
    lfs_unmount(&lfs) => 0;
TEST

echo "--- Set/get root attribute ---"
tests/test.py << TEST
    lfs_mount(&lfs, &cfg) => 0;
    lfs_setattr(&lfs, "/", 'A', "aaaa",   4) => 0;
    lfs_setattr(&lfs, "/", 'B', "bbbbbb", 6) => 0;
    lfs_setattr(&lfs, "/", 'C', "ccccc",  5) => 0;
    lfs_getattr(&lfs, "/", 'A', buffer,    4) => 4;
    lfs_getattr(&lfs, "/", 'B', buffer+4,  6) => 6;
    lfs_getattr(&lfs, "/", 'C', buffer+10, 5) => 5;
    memcmp(buffer,    "aaaa",   4) => 0;
    memcmp(buffer+4,  "bbbbbb", 6) => 0;
    memcmp(buffer+10, "ccccc",  5) => 0;

    lfs_setattr(&lfs, "/", 'B', "", 0) => 0;
    lfs_getattr(&lfs, "/", 'A', buffer,    4) => 4;
    lfs_getattr(&lfs, "/", 'B', buffer+4,  6) => 0;
    lfs_getattr(&lfs, "/", 'C', buffer+10, 5) => 5;
    memcmp(buffer,    "aaaa",         4) => 0;
    memcmp(buffer+4,  "\0\0\0\0\0\0", 6) => 0;
    memcmp(buffer+10, "ccccc",        5) => 0;

    lfs_setattr(&lfs, "/", 'B', "dddddd", 6) => 0;
    lfs_getattr(&lfs, "/", 'A', buffer,    4) => 4;
    lfs_getattr(&lfs, "/", 'B', buffer+4,  6) => 6;
    lfs_getattr(&lfs, "/", 'C', buffer+10, 5) => 5;
    memcmp(buffer,    "aaaa",   4) => 0;
    memcmp(buffer+4,  "dddddd", 6) => 0;
    memcmp(buffer+10, "ccccc",  5) => 0;

    lfs_setattr(&lfs, "/", 'B', "eee", 3) => 0;
    lfs_getattr(&lfs, "/", 'A', buffer,    4) => 4;
    lfs_getattr(&lfs, "/", 'B', buffer+4,  6) => 3;
    lfs_getattr(&lfs, "/", 'C', buffer+10, 5) => 5;
    memcmp(buffer,    "aaaa",      4) => 0;
    memcmp(buffer+4,  "eee\0\0\0", 6) => 0;
    memcmp(buffer+10, "ccccc",     5) => 0;

    lfs_setattr(&lfs, "/", 'A', buffer, LFS_ATTR_MAX+1) => LFS_ERR_NOSPC;
    lfs_setattr(&lfs, "/", 'B', "fffffffff", 9) => 0;
    lfs_getattr(&lfs, "/", 'A', buffer,    4) => 4;
    lfs_getattr(&lfs, "/", 'B', buffer+4,  6) => 9;
    lfs_getattr(&lfs, "/", 'C', buffer+10, 5) => 5;
    lfs_unmount(&lfs) => 0;
TEST
tests/test.py << TEST
    lfs_mount(&lfs, &cfg) => 0;
    lfs_getattr(&lfs, "/", 'A', buffer,    4) => 4;
    lfs_getattr(&lfs, "/", 'B', buffer+4,  9) => 9;
    lfs_getattr(&lfs, "/", 'C', buffer+13, 5) => 5;
    memcmp(buffer,    "aaaa",      4) => 0;
    memcmp(buffer+4,  "fffffffff", 9) => 0;
    memcmp(buffer+13, "ccccc",     5) => 0;

    lfs_file_open(&lfs, &file[0], "hello/hello", LFS_O_RDONLY) => 0;
    lfs_file_read(&lfs, &file[0], buffer, sizeof(buffer)) => strlen("hello");
    memcmp(buffer, "hello", strlen("hello")) => 0;
    lfs_file_close(&lfs, &file[0]);
    lfs_unmount(&lfs) => 0;
TEST

echo "--- Set/get file attribute ---"
tests/test.py << TEST
    lfs_mount(&lfs, &cfg) => 0;
    struct lfs_attr a1 = {'A', buffer,    4};
    struct lfs_attr b1 = {'B', buffer+4,  6, &a1};
    struct lfs_attr c1 = {'C', buffer+10, 5, &b1};
    struct lfs_file_config cfg1 = {.attrs = &c1};

    lfs_file_opencfg(&lfs, &file[0], "hello/hello", LFS_O_WRONLY, &cfg1) => 0;
    memcpy(buffer,    "aaaa",   4);
    memcpy(buffer+4,  "bbbbbb", 6);
    memcpy(buffer+10, "ccccc",  5);
    lfs_file_close(&lfs, &file[0]) => 0;
    memset(buffer, 0, 15);
    lfs_file_opencfg(&lfs, &file[0], "hello/hello", LFS_O_RDONLY, &cfg1) => 0;
    lfs_file_close(&lfs, &file[0]) => 0;
    memcmp(buffer,    "aaaa",   4) => 0;
    memcmp(buffer+4,  "bbbbbb", 6) => 0;
    memcmp(buffer+10, "ccccc",  5) => 0;

    b1.size = 0;
    lfs_file_opencfg(&lfs, &file[0], "hello/hello", LFS_O_WRONLY, &cfg1) => 0;
    lfs_file_close(&lfs, &file[0]) => 0;
    memset(buffer, 0, 15);
    b1.size = 6;
    lfs_file_opencfg(&lfs, &file[0], "hello/hello", LFS_O_RDONLY, &cfg1) => 0;
    lfs_file_close(&lfs, &file[0]) => 0;
    memcmp(buffer,    "aaaa",         4) => 0;
    memcmp(buffer+4,  "\0\0\0\0\0\0", 6) => 0;
    memcmp(buffer+10, "ccccc",        5) => 0;

    b1.size = 6;
    lfs_file_opencfg(&lfs, &file[0], "hello/hello", LFS_O_WRONLY, &cfg1) => 0;
    memcpy(buffer+4,  "dddddd", 6);
    lfs_file_close(&lfs, &file[0]) => 0;
    memset(buffer, 0, 15);
    b1.size = 6;
    lfs_file_opencfg(&lfs, &file[0], "hello/hello", LFS_O_RDONLY, &cfg1) => 0;
    lfs_file_close(&lfs, &file[0]) => 0;
    memcmp(buffer,    "aaaa",   4) => 0;
    memcmp(buffer+4,  "dddddd", 6) => 0;
    memcmp(buffer+10, "ccccc",  5) => 0;

    b1.size = 3;
    lfs_file_opencfg(&lfs, &file[0], "hello/hello", LFS_O_WRONLY, &cfg1) => 0;
    memcpy(buffer+4,  "eee", 3);
    lfs_file_close(&lfs, &file[0]) => 0;
    memset(buffer, 0, 15);
    b1.size = 6;
    lfs_file_opencfg(&lfs, &file[0], "hello/hello", LFS_O_RDONLY, &cfg1) => 0;
    lfs_file_close(&lfs, &file[0]) => 0;
    memcmp(buffer,    "aaaa",      4) => 0;
    memcmp(buffer+4,  "eee\0\0\0", 6) => 0;
    memcmp(buffer+10, "ccccc",     5) => 0;

    a1.size = LFS_ATTR_MAX+1;
    lfs_file_opencfg(&lfs, &file[0], "hello/hello", LFS_O_WRONLY, &cfg1)
        => LFS_ERR_NOSPC;

    struct lfs_attr a2 = {'A', buffer,    4};
    struct lfs_attr b2 = {'B', buffer+4,  9, &a2};
    struct lfs_attr c2 = {'C', buffer+13, 5, &b2};
    struct lfs_file_config cfg2 = {.attrs = &c2};
    lfs_file_opencfg(&lfs, &file[0], "hello/hello", LFS_O_RDWR, &cfg2) => 0;
    memcpy(buffer+4,  "fffffffff", 9);
    lfs_file_close(&lfs, &file[0]) => 0;
    a1.size = 4;
    lfs_file_opencfg(&lfs, &file[0], "hello/hello", LFS_O_RDONLY, &cfg1) => 0;
    lfs_file_close(&lfs, &file[0]) => 0;

    lfs_unmount(&lfs) => 0;
TEST
tests/test.py << TEST
    lfs_mount(&lfs, &cfg) => 0;
    struct lfs_attr a2 = {'A', buffer,    4};
    struct lfs_attr b2 = {'B', buffer+4,  9, &a2};
    struct lfs_attr c2 = {'C', buffer+13, 5, &b2};
    struct lfs_file_config cfg2 = {.attrs = &c2};

    lfs_file_opencfg(&lfs, &file[0], "hello/hello", LFS_O_RDONLY, &cfg2) => 0;
    lfs_file_close(&lfs, &file[0]) => 0;
    memcmp(buffer,    "aaaa",      4) => 0;
    memcmp(buffer+4,  "fffffffff", 9) => 0;
    memcmp(buffer+13, "ccccc",     5) => 0;

    lfs_file_open(&lfs, &file[0], "hello/hello", LFS_O_RDONLY) => 0;
    lfs_file_read(&lfs, &file[0], buffer, sizeof(buffer)) => strlen("hello");
    memcmp(buffer, "hello", strlen("hello")) => 0;
    lfs_file_close(&lfs, &file[0]);
    lfs_unmount(&lfs) => 0;
TEST

echo "--- Deferred file attributes ---"
tests/test.py << TEST
    lfs_mount(&lfs, &cfg) => 0;
    struct lfs_attr a1 = {'B', "gggg", 4};
    struct lfs_attr b1 = {'C', "",     0, &a1};
    struct lfs_attr c1 = {'D', "hhhh", 4, &b1};
    struct lfs_file_config cfg1 = {.attrs = &c1};

    lfs_file_opencfg(&lfs, &file[0], "hello/hello", LFS_O_WRONLY, &cfg1) => 0;

    lfs_getattr(&lfs, "hello/hello", 'B', buffer,    9) => 9;
    lfs_getattr(&lfs, "hello/hello", 'C', buffer+9,  9) => 5;
    lfs_getattr(&lfs, "hello/hello", 'D', buffer+18, 9) => 0;
    memcmp(buffer,    "fffffffff",          9) => 0;
    memcmp(buffer+9,  "ccccc\0\0\0\0",      9) => 0;
    memcmp(buffer+18, "\0\0\0\0\0\0\0\0\0", 9) => 0;

    lfs_file_sync(&lfs, &file[0]) => 0;
    lfs_getattr(&lfs, "hello/hello", 'B', buffer,    9) => 4;
    lfs_getattr(&lfs, "hello/hello", 'C', buffer+9,  9) => 0;
    lfs_getattr(&lfs, "hello/hello", 'D', buffer+18, 9) => 4;
    memcmp(buffer,    "gggg\0\0\0\0\0",     9) => 0;
    memcmp(buffer+9,  "\0\0\0\0\0\0\0\0\0", 9) => 0;
    memcmp(buffer+18, "hhhh\0\0\0\0\0",     9) => 0;

    lfs_file_close(&lfs, &file[0]) => 0;
    lfs_unmount(&lfs) => 0;
TEST

echo "--- Results ---"
tests/stats.py