#!/bin/bash
hexo generate && hexo deploy && ./qrsync config.json
