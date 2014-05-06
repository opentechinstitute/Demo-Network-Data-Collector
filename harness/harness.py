#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import socketserver 


class TestHandler(socketserver.StreamRequestHandler):
    def handle(self):
        while True:
            data = self.connection.recv(4096).strip()
            if not data:
                break
            print(data)
#            self.wfile.write(b"Connection Commenced\n")

class HarnessServer(socketserver.TCPServer):

    def __init__(self, server_address, handler_class):
        print("initializing")
        super().__init__(server_address, handler_class)

    def get_request(self):
        newsocket, fromaddr = self.socket.accept()
        print("got request")
        return newsocket, fromaddr

class ThreadingTCPServer(socketserver.ThreadingMixIn, HarnessServer):
    pass

if __name__ == "__main__":
    ThreadingTCPServer(('', 5151), TestHandler).serve_forever()
