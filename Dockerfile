#
#  From this base-image / starting-point
#
FROM debian:testing

#
#  Authorship
#
MAINTAINER ap13@sanger.ac.uk

#
# Pull in packages from testing
#
RUN apt-get update -qq && apt-get install -y roary
