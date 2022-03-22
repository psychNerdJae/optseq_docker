# Running optseq2 via Docker

The program [`optseq2`](https://surfer.nmr.mgh.harvard.edu/optseq/) remains one of the most useful tools for generating efficient fMRI event-related designs. Unfortunately, the binaries for Apple and Windows were written in the early 2000s, and can no longer be run on modern computers (or if they can, I haven't figured out how to do it after sinking 20+ hours on both OSes).

Happily, the x86-64 Linux version of optseq2 is still operational. Unhappily, many researchers don't have consistent access to a Linux box, and in any case, don't really know how to use one (full disclosure: I count myself a part of this group of "many" researchers).

Instead, we'll use a Docker container as a sort of "emulation" layer. I've successfully gotten this to work on macOS 12.2.1 (Monterey) on a 2021 MacBook Pro with the M1 Pro chipset.

## Code example

If you'd prefer not to read an annotated version of my code example, here's the code without commentary. If you want to read explanations for how each section works, read on.

```bash
cd ~/Documents/GitHub/optseq_docker
docker build -t optseq .

cd ~/Desktop
mkdir -m 775 optseq_demo

docker run --rm -it -v ~/Desktop/optseq_demo:/data optseq bash

./optseq2 --ntp 150 --tr 2 --psdwin 0 16 2 \
--ev stim_01 1 5 \
--ev stim_02 1 5 \
--ev stim_03 1 5 \
--ev stim_04 1 5 \
--ev stim_05 1 5 \
--ev stim_06 1 5 \
--ev stim_07 1 5 \
--ev stim_08 1 5 \
--ev stim_09 1 5 \
--ev catch 1 5 \
--tnullmin 1 --tnullmax 10 --nkeep 10 --o TestOptSeq --nsearch 100

mv ./TestOptSeq* ./data

exit
```

## Setup

First, you'll need to [install Docker](https://www.docker.com/products/personal/). If you're not familiar with what Docker is, or what makes it useful, [read this beginner-friendly explainer by Microsoft](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/container-docker-introduction/docker-defined).

Next, you'll need to clone this repository to your computer's hard drive. In my case, I have the repository stored at `~/Documents/GitHub/optseq_docker`. The repository contains a `Dockerfile` that provides Docker with instructions on how to build a new *image*. Once you've built an image, that image will stay stored on your computer's hard drive, so you only need to build an image once. For Docker beginners, it's important to note that the same image can be used to create multiple *containers*, and that each container is a self-contained computing environment that operates independently from all other containers.

Once you open up a Terminal window, here's how to create our Docker container:

```bash
cd ~/Documents/GitHub/optseq_docker
docker build -t optseq .
```

For testing purposes, we'll create a new folder in your Desktop.

```bash
cd ~/Desktop
mkdir -m 775 optseq_demo
```

## Running a Docker container

The below command starts a new container from our `optseq` image. The flag `--rm` simply tells Docker to remove the container once it is closed; otherwise, it would stick around on your hard drive. The flags `-it` tell Docker that we want to run the program `i`nteractively, using the `t`erminal. At the end, we have an argument `bash` that tells Docker that we want to use the terminal as if we're inside the container.

What's going on with the flag for `-v`? This tells Docker that we want to use a `v`olume mount, which allows the Docker container to share data with your computer (i.e., the *host*). If there were any files inside the host folder `/Desktop/optseq_demo`, those files would automatically be available inside the container folder `/data`. Likewise, when we generate output files from optseq, we can "transfer" that output to our host computer by moving relevant files into `data`.

```bash
docker run --rm -it -v ~/Desktop/optseq_demo:/data optseq bash
```

## Running optseq

At this point, our terminal window is "inside" the container. If you use commands like `ls` to list files, you'll no longer see the directory structure of your host, but will instead see the directory structure of the container.

It's somewhat outside the scope of this readme to do a full deep-dive into using optseq, but here's an illustrative example that can serve as a useful template.

If you simply type `./optseq2`, it calls the program. Without any further arguments, it will pull up the help documentation, which you should read.

The flag `--ntp` is for the `n`umber of `t`ime`p`oints, and represents the number of TRs you'll generate in each run. If you're using a standard TR of 2 seconds, for example, the total run time will be `ntp * TR`.

You can probably guess what the flag for `--tr` does.

The flag `--psdwin` basically formalizes your assumptions about the window of time in which the full neural response can be captured. In our example, we assume that the neural response to each event happens 0-16 seconds after the event onset, and can be sampled in increments of 2 seconds.

Each call to `--ev` defines a new event. You should try to name your events something informative. The first numeric argument specifies the event duration, and the second numeric argument specifies the number of repetitions within a given run.

The flag `--o` ensures that all `o`utput files start with this prefix.

The flags `--tnullmin` and `--tnullmax` specify the `min`imum and `max`imum `t`ime that the study presents a `null` "event". In many studies, this is the fixation cross displayed between "real" stimuli.

Finally, the flags `--nkeep` and `--nsearch` specify how many event schedules to search over, and of the generated schedules, how many to keep. Remember that you will ultimately want to generate a minimum of `nkeep = n_runs_per_participant * n_participants`.

```bash
./optseq2 --ntp 150 --tr 2 --psdwin 0 16 2 \
--ev stim_01 1 5 \
--ev stim_02 1 5 \
--ev stim_03 1 5 \
--ev stim_04 1 5 \
--ev stim_05 1 5 \
--ev stim_06 1 5 \
--ev stim_07 1 5 \
--ev stim_08 1 5 \
--ev stim_09 1 5 \
--ev catch 1 5 \
--o TestOptSeq --tnullmin 1 --tnullmax 10 --nkeep 10 --nsearch 100
```

## Cleanup

By default, optseq will save output files in whatever directory you happen to be in. In order to share this output with the host, we need to move all relevant files into `/data`. Then we want to exit the container.

```bash
mv ./TestOptSeq* ./data

exit
```

Now, you can go to your desktop and see that the optseq output is now inside `optseq_demo`.

If you prefer to read the help documentation in a browser instead of a terminal, you can [find this documentation here](https://surfer.nmr.mgh.harvard.edu/optseq/optseq2.help.txt).
