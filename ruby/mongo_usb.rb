#!/usr/bin/env ruby

DISK_NAME = 'MONGODB'

def all_disks
  `diskutil list`.scan(/\/dev\/disk\d/)
end

def is_generic_flash_disk?(disk)
  `diskutil info #{disk}` =~ /Device \/ Media Name: \s* Generic Flash Disk Media/
end

def usb_sticks
  all_disks.select {|disk| is_generic_flash_disk?(disk)}
end

def partition_usb_stick(stick)
  puts "[part] partitioning and formatting #{stick}"
  `diskutil partitionDisk #{stick} 1 MBR fat32 #{DISK_NAME} 100%`
end

def partition_usb_sticks
  usb_sticks.each {|stick| partition_usb_stick(stick)}
end

def copy_data(directory)
  usb_sticks.each do |stick|
    puts "[umnt] #{stick}"
    `diskutil unmount #{stick}s1`
    puts "[mnt] #{stick}"
    `diskutil mount #{stick} -mountPoint /Volumes/usbstick`
    puts "[copy] #{directory} -> #{stick}"
    `cp -r #{directory}/* /Volumes/usbstick`
  end
end

unless ARGV[0]
  puts "No source directory for MongoDB files!"
  puts "Usage: mongousb /path/to/mongodb/files"
  exit
end

partition_usb_sticks
copy_data(ARGV[0])
