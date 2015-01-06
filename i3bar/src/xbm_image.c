#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

#include "xbm_image.h"

#if FILENAME_CHECKING
/* Assume that file is called xxx.xbm, get xxx out of the filename
   for furhter validation during parsing.  */
static char *
validate_fname (char *  fname)
{
    char *  dot = strrchr (fname, '.');
    char *  slash = strrchr (fname, '/');
    char *  ret = NULL;
    unsigned sz = 0;

    if (NULL == dot)
        return NULL;

    if (0 != strncmp (dot, ".xbm", 4))
        return NULL;

    if (slash)
        fname = slash + 1;

    sz = dot - fname;
    ret = malloc (sz + 1);
    strncpy (ret, fname, sz);
    ret[sz] = 0;
    return ret;
}
#endif

static char *
read_id (FILE *  f)
{
    unsigned sz = 2, ptr = 0;
    char * data = malloc (sz);
    int c;

    c = fgetc (f);
    if (isalpha (c) || c == '_')
        data[ptr++] = c;
    else
        goto out;

    while (true) {
        c = fgetc (f);
        if (ptr == sz - 1)
            data = realloc (data, sz *= 2);

        if (isalnum (c) || c == '_')
            data[ptr++] = c;
        else {
            ungetc (c, f);
            break;
        }
    }

    data[ptr] = '\0';
    return data;

out:
    if (data)
        free (data);

    return NULL;
}


static bool
read_string (FILE *  f, const char *  s)
{
    while (*s != '\0') {
        int c = fgetc (f);
        if (c == EOF || c != *s) {
            ungetc (c, f);
            return false;
        }
        s++;
    }

    return true;
}

static bool
skip_spaces (FILE *  f)
{
    int c;
    while (isspace (c = fgetc (f)) && c != EOF)
        ;

    ungetc (c, f);
    return true;
}

static inline bool
string_ends_with (const char *  s, const char *  postfix)
{
    return strlen (s) > strlen (postfix)
    && strncmp (s + strlen (s) - strlen (postfix),
                postfix, strlen (postfix)) == 0;
}

#define READ_WORD_EAT_SPACES(file, word)    \
do {                                            \
    if (!read_string (file, word))            \
        return false;                            \
    skip_spaces (file);                            \
} while (0)


static bool
read_define (FILE *  f, struct xbm_image *  img)
{
    unsigned sz;
    char *  wh;

    READ_WORD_EAT_SPACES (f, "define");

    /* read the <id>_width variable, and save <id> for
       later validation in the img.  */
    if (NULL == (wh = read_id (f)))
        return false;

    if (string_ends_with (wh, "_width")) {
        if (!img->id) {
            unsigned idsz = strlen (wh) - strlen ("_width");
            img->id = malloc (idsz+1);
            strncpy (img->id, wh, idsz);
            img->id[idsz] = '\0';
        } else if (0 != strncmp (img->id, wh, strlen (img->id))) {
            free (wh);
            return false;
        }

        free (wh);
        skip_spaces (f);
        if (fscanf (f, "%u", &sz) < 1)
            return false;

        img->width = sz;
    } else if (string_ends_with (wh, "_height")) {
            if (!img->id) {
            unsigned idsz = strlen (wh) - strlen ("_height");
            img->id = malloc (idsz+1);
            strncpy (img->id, wh, idsz);
            img->id[idsz] = '\0';
        } else if (0 != strncmp (img->id, wh, strlen (img->id))) {
            free (wh);
            return false;
        }

        free (wh);
        skip_spaces (f);
        if (fscanf (f, "%u", &sz) < 1)
            return false;

        img->height = sz;
    } else
        return false;

    return true;
}

static bool
read_data (FILE *  f, struct xbm_image *  img)
{
    int sz, i;
    char *  data;

    /* size in bytes  */
    sz = (img->width / 8 + !!(img->width % 8)) * img->height;

    data = malloc (sz);

    READ_WORD_EAT_SPACES (f, "tatic");
    READ_WORD_EAT_SPACES (f, "unsigned");
    READ_WORD_EAT_SPACES (f, "char");
    READ_WORD_EAT_SPACES (f, img->id);
    READ_WORD_EAT_SPACES (f, "_bits[]");
    READ_WORD_EAT_SPACES (f, "=");
    READ_WORD_EAT_SPACES (f, "{");

    for (i = 0; i < sz; i++) {
        unsigned value;
        if (fscanf (f, "%x", &value) < 1 || value > 255)
            return false;

        data[i] = (char)value;
        skip_spaces (f);
        if (i != sz - 1)
            READ_WORD_EAT_SPACES (f, ",");
    }

    READ_WORD_EAT_SPACES (f, "}");
    READ_WORD_EAT_SPACES (f, ";");
    img->data = data;
    return true;
}


struct xbm_image *
xbm_from_file (char *  fname)
{
    struct xbm_image *  img = NULL;
    FILE *  f = NULL;
    int c;

    if (!(f = fopen (fname, "r")))
        goto out;

    img = malloc (sizeof (struct xbm_image));
    img->id = NULL;
    img->width = -1;
    img->height = -1;

    do {
        c = fgetc (f);
        if (c == '#') {
            if (!read_define (f, img))
                goto out;
        } else if (c == 's') {
            if (img->width == -1 || img->height == -1 || !img->id
                ||  !read_data (f, img))
                goto out;
        } else if (isspace (c) || c == EOF)
            ;
        else
            goto out;
    } while (c != EOF);

    fclose (f);
    return img;

out:
    if (f)
        fclose (f);

    return NULL;
}

void
xbm_free (struct xbm_image *  img)
{
    if (!img)
        return;

    if (img->id)
        free (img->id);
    if (img->data)
        free (img->data);

    free (img);
}

#ifdef TESTING
int
main (int argc, char *argv[])
{
    struct xbm_image *  img;
    int i;

    img = xbm_from_file (argv[1]);

    if (img != NULL) {
        for (i = 0; i < (img->width /8 + !!(img->width % 8)) * img->height; i++)
            printf ("%x, ", (unsigned char)img->data[i]);

        xbm_free (img);
    }

    return EXIT_SUCCESS;
}
#endif
