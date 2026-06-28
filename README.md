# containers-devcontainers-hardening

Devcontainers seem like a really cool thing Id want to try anyway as its a portable dev setup and can even use it in the cloud - GitHub Codespaces.
Since they are just based on containers hardening those appies to all containers.

I have some projects I want to install, python ones and I'm not a python dev and I really dont care..
It may be a one time thing and I want to stay secure..
Still I want some convenience..

I am thinking devcontainers -> contrainers -> VM, and as you go right it can potentailly get more secure but less convenient.

Containers, can be secure just depends how you configure them.. do you run docker rootless, is you user in container root and etc...
I suppose I can just have a well isolated container I can ssh into.

Devcontainers (have all the risks of containers) but additioanllly do a lot cool things to make your life easier, which increases risk further.

VM is the least risk but also the least convenient.. And actually maybe kind of impossible since I'm always low on storage.

https://itnext.io/security-hardening-of-your-dev-containers-with-docker-hardened-images-dhi-io-2bfb5d299b7f
https://gitlab.com/lx-industries/setup-devcontainer-skill
https://blog.theredguild.org/where-do-you-run-your-code-part-ii-2/
https://socket.dev/blog/introducing-socket-firewall
https://bernat.tech/posts/securing-python-supply-chain/


https://blog.theredguild.org/where-do-you-run-your-code/
https://github.com/Cyfrin/web3-dev-containers
https://github.com/theredguild/devcontainer


## Hardening Docker on Mac

Not sure if I can run it rootless, but on Mac we already have some more isoltaion cause we run in a linux VM.
Podman I think is just rootless by default, but some tooling like LocalStack may not play nice with it.

At any rate, there are some advanced privilages you can check in the GUI and uncheck what you don't need.

## Hardening Docker on Ubuntu

I think here, we can try making that rootless, as we don't have the VM isolation we have on Mac.

## Hardening Images/Containers

Here, we are going to spend most of our time. Basing a lot of this on few really great blogs and some LLM suggestions.

## Python

Apperently people are rooting for "uv", a single tool that replaces all other ones - pip, vnev, pyenv, idk etc.
And I am liking that - it seems like pnpm -> does all things that npm does not do by default but really should.
And you can also specify a min release age cooldown.

## Node

Use Deno where you can specify file system and netwrok access permissions.

Node as well https://nodejs.org/docs/latest-v26.x/api/permissions.html
But it doenst look like this gives any security guarantees, at least on Node...
