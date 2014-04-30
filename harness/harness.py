#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Simple ssl socket server from https://stackoverflow.com/a/19803457

Written by  https://stackoverflow.com/users/2936276/warriorpaw

"""

from socketserver import TCPServer, ThreadingMixIn, StreamRequestHandler
import ssl

class HarnessServer(TCPServer):
    def __init__(self,
                 server_address,
                 RequestHandlerClass,
                 certfile,
                 keyfile,
                 ssl_version=ssl.PROTOCOL_TLSv1,
                 bind_and_activate=True):
        TCPServer.__init__(self, server_address, RequestHandlerClass, bind_and_activate)
        self.certfile = certfile
        self.keyfile = keyfile
        self.ssl_version = ssl_version

    def get_request(self):
        newsocket, fromaddr = self.socket.accept()
        connstream = ssl.wrap_socket(newsocket,
                                 server_side=True,
                                 certfile = self.certfile,
                                 keyfile = self.keyfile,
                                 ssl_version = self.ssl_version)
        return connstream, fromaddr

class MySSL_ThreadingTCPServer(ThreadingMixIn, HarnessServer): pass

class testHandler(StreamRequestHandler):
    def handle(self):
        data = self.connection.recv(4096)
        self.wfile.write(data)


if __name__ == "__main__":
    MySSL_ThreadingTCPServer(('',5151),testHandler,"temp/cert.pem","temp/key.pem").serve_forever()
