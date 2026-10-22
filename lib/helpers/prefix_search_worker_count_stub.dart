/// Web / non-IO platforms: no multi-isolate worker pool.
int get parallelPrefixSearchWorkers => 1;

bool get supportsParallelPrefixIsolates => false;
