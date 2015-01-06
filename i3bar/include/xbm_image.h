#ifndef __XBM_IMAGE_H__
#define __XBM_IMAGE_H__

struct xbm_image {
    int width, height;
    char *  id;
    char *  data;
};


struct xbm_image *  xbm_from_file (char *);
void xbm_free (struct xbm_image *);

#endif /* __XBM_IMAGE_H__  */
