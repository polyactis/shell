#!/bin/bash
for i in $(cat tmp); do
	echo item: $i
	rm $i -rf
done
