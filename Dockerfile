FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -y gcc git-core make && \
    apt-get clean

WORKDIR /opt

# installing nim-lang
RUN git clone https://github.com/Araq/Nim.git && \
    cd Nim && \
    git clone https://github.com/nim-lang/csources.git && \
    ( cd csources &&  sh build.sh ) && \
    ./bin/nim compile koch && \
    ./koch boot --define:release && \
    chmod a+x /opt/Nim/bin/nim && \
    find /opt/Nim -type f -a  -name '*.o' -print | xargs rm && \
    ln -s /opt/Nim/bin/nim /usr/bin/nim

# installing nimble
# nimble is a package manager for the nim-lang
RUN git clone https://github.com/nim-lang/nimble.git && \
    ( cd nimble && nim compile --run src/nimble install ) && \
    find /opt/nimble -type f -a  -name '*.o' -print | xargs rm && \
    ln -s /opt/nimble/src/nimble /usr/bin/nimble

RUN useradd --create-home --shell /bin/bash nim && \
    echo 'nim:nim' | chpasswd && \
    echo 'nim ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/nim && \
    echo 'PATH="$HOME/.nimble/bin:$PATH"' >> /home/nim/.profile
RUN sudo -u nim -i nimble update
ADD example /home/nim/example
RUN chown -R nim:nim /home/nim/example

CMD ["sudo", "-u", "nim", "-i"]