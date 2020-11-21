#!/bin/bash

p.myjobs(){
    _p.require_ordenv
    jobst | grep ${USER} -n
}
