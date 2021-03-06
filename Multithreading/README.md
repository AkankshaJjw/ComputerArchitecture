Akanksha Jhunjhunwala

Problem: To implement a multi-threaded tracker and analyzer for video processing that takes in the Lenna image and rotates it 90 degrees counter- clockwise.

Find: Analyze the thread processing time for this application and analyze the individual threads.

Solution: Two threads are created, one for digitizer(), and one for tracker(). A thread for main is created automatically by the OS when the application is run. The three threads are shown in the screenshot below. The first thread is for digitizer, the second one is for tracker, and the third one is the automatically generated main thread.

![](https://github.com/AkankshaJjw/ComputerArchitecture/blob/master/Multithreading/threads.JPG)

The digitizer grabs an image from the buffer and the tracker analyzes it by rotating it 90 degrees to the left and storing it in a new file. The old and new files are shown side by side below.

![](https://github.com/AkankshaJjw/ComputerArchitecture/blob/master/Multithreading/images.JPG)

![](https://github.com/AkankshaJjw/ComputerArchitecture/blob/master/Multithreading/threads2.JPG)

Analysis: The thread condition variables, buf\_notempty and buf\_notfull allow each thread to wait on a condition and blocks for a signal using pthread\_cond\_wait until the other thread signals it to wake up using pthread\_cond\_signal. In this screenshot showing the three threads, the highlighted thread, which is the thread for digitizer, is in the &#39;Wait:WrPushLock&#39; state, meaning that it is currently waiting for the buffer to not be full while the other thread is executing. It is seen that the second thread consumes much more cpu power than the first one which can be explained by the fact that it does more I/O operation and also has a nested for loop for rotating the image.

![](https://github.com/AkankshaJjw/ComputerArchitecture/blob/master/Multithreading/proc_time.JPG)
The % processor time of each thread is shown in the performance report below. The pits in the graph for each thread indicate the times when that thread was blocked. The peaks could refer to the times when the thread was carrying out a more intensive operator, such as file IO.

![](https://github.com/AkankshaJjw/ComputerArchitecture/blob/master/Multithreading/priv_time.JPG)
The significant amount of % privileged time is the amount of time being spent in the Windows kernel executing system calls such as IO calls. The thread for analyzer has more % privileged time since it has a nested for loop that does an fwrite IO operation.

The memory consumed by the process is shown here. The image itself takes about 66 KB of memory since it is a 512 x 512 x 255 char array. The amount of space consumed remains constant as the program runs because once the Lenna image has been fetched, it is stored in cache. Since the threads share a common memory, page table, etc., it is not possible to look at their individual memory consumption. Analytically, both the threads take up about the same amount of memory as they each define a pointer to char for storing the image and a pointer to FILE. ![](https://github.com/AkankshaJjw/ComputerArchitecture/blob/master/Multithreading/const.JPG)

An analysis report of the entire process is included which again showed that even though the amount of data read and written kept increasing as the program ran and continually read and wrote back the image, the space considerations remained the same due to the image being held in cache.

![](https://github.com/AkankshaJjw/ComputerArchitecture/blob/master/Multithreading/perf.JPG)

The state of the threads at different times is shown below, where the higher value(5) means that it is in the wait state, while the lower value(2) means that it is running. The thread wait reason is applicable only when it is in the wait state and in our case corresponds to waiting for a common data structure, bufavail, based on the condition variables as explained before. 
![](https://github.com/AkankshaJjw/ComputerArchitecture/blob/master/Multithreading/thr_state.JPG)

