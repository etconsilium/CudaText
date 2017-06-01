import sys
import os
import re
import platform
import tempfile
import cudatext as app
from .work_remote import *

p = sys.platform
X64 = platform.architecture()[0]=='64bit'
##p = 'win32'
##X64 = False

DOWNLOAD_PAGE = \
    'https://sourceforge.net/projects/cudatext/files/release/Linux/' if p=='linux'\
    else 'https://sourceforge.net/projects/cudatext/files/release/Windows/' if p=='win32'\
    else 'https://sourceforge.net/projects/cudatext/files/release/macOS/' if p=='darwin'\
    else '?'

if p=='darwin':
    TEXT_CPU = ''
else:
    TEXT_CPU = '64' if X64 else '(386|32)'

DOWNLOAD_REGEX = \
    ' href="(\w+://[\w\.]+/projects/cudatext/files/release/\w+/cudatext-[\w\-]+?'+TEXT_CPU+'[\w\-]*?-([\d\.]+?)\.(zip|dmg|tar\.xz)/download)"'



def check_cudatext():

    fn = os.path.join(tempfile.gettempdir(), 'cudatext_download.html')
    app.msg_status('Downloading: '+DOWNLOAD_PAGE, True)
    get_url(DOWNLOAD_PAGE, fn, True)
    app.msg_status('')

    if not os.path.isfile(fn):
        app.msg_status('Cannot download: '+DOWNLOAD_PAGE)
        return

    text = open(fn, encoding='utf8').read()
    items = re.findall(DOWNLOAD_REGEX, text)
    if not items:
        app.msg_status('Cannot find download links')
        return

    items = sorted(items, key=lambda i:i[1], reverse=True)
    print('Found links:')
    for i in items:
        print('  ', i[0])

    url = items[0][0]
    ver = items[0][1]
    ver_local = app.app_exe_version()
    ###ver_local = '0' #to test

    if ver<=ver_local:
        app.msg_box('Latest CudaText is already here\nLocal: %s\nWeb: %s'%(ver_local, ver), app.MB_OK+app.MB_ICONINFO)
        return

    text = '\n'.join([
        'type=label\1pos=6,20,500,0\1cap=CudaText newer version is available at this URL:',
        'type=linklabel\1pos=20,45,600,0\1cap='+url+'\1props='+url+'\1font_size=8',
        'type=button\1pos=300,100,400,0\1cap=OK\1props=1'
        ])
    app.dlg_custom('CudaText update', 700, 130, text)
