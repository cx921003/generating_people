#!/usr/bin/env python2
"""Main control for the experiments."""

import numpy as np
import os.path as path
import os
import click

@click.command()
@click.argument("image_dir",
                type=click.Path(exists=True, writable=True, file_okay=False))

def cli(**args):
    """Append or create the presentation html file for the images."""
    image_dir = args['image_dir'].strip("/")

    index_path = path.join(path.dirname(image_dir), "index_full.html")
    if path.exists(index_path):
        index = open(index_path, "a")
    else:
        index = open(index_path, "w")
        index.write("<html>\n<body>\n<table>\n<tr>")
        colnames = ['name']
        name = None
        for root, folder, files in os.walk(image_dir):
            for file in sorted(files):
                suffix = path.basename(file).split('.')[-1]
                if suffix != 'png':
                    continue
                print path.basename(file)
                if name is None:
                    name = path.basename(file).split('.')[0].rsplit('_', 1)[0]
                elif name != path.basename(file).split('.')[0].rsplit('_', 1)[0]:
                    break
                coln = path.basename(file).split('.')[0].rsplit('_', 1)[-1]
                if coln not in colnames:
                    colnames.append(coln)
        for coln in colnames:
            index.write("<th>%s</th>\n" % (coln))
        index.write("</tr>\n")

    name = None
    for root, folder, files in os.walk(image_dir):
        for file in sorted(files):
            suffix = path.basename(file).split('.')[-1]
            if suffix != 'png':
                continue
            if name != path.basename(file).split('.')[0].rsplit('_',1)[0]:
                name = path.basename(file).split('.')[0].rsplit('_',1)[0]
                index.write("<tr>\n")
                index.write("<td>%s</td>" % (name))
            index.write("<td><img src='images/%s'></td>" % (path.basename(file)))

    index.write("</tr>\n")

    return index_path

if __name__ == '__main__':

    cli()
