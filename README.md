# 1️⃣ 🏎️Treys Implementations of The One Billion Row Challenge

This repo is a form of the original Java 1BRC that contains the solutions for various programming languages I have toyed round with for this challenge life on Twitch at https://twitch.tv/trey_bastian.

## Results

All results were recorded using an Intel 12900K with 64GB of DDR5 Ram while streaming to Twitch.

### Dart

`./evalutate.sh dart`
avg time: 78s

There are still improvements that can be made to how we are collating results from Isolates and how we are processing individual lines along with optimizing heap allocations.

### COBOL

`./evalutate.sh cobol`
avg time: 16m

There are potential improvements with exploring utilising subprograms to enable utilization of more processor cores to process the file better. There are additional optimizations that can be made with how we process chunks and files.

## The Challenge

The One Billion Row Challenge (1BRC) is a fun exploration of how far modern Java can be pushed for aggregating one billion rows from a text file.
Grab all your (virtual) threads, reach out to SIMD, optimize your GC, or pull any other trick, and create the fastest implementation for solving this task!

<img src="1brc.png" alt="1BRC" style="display: block; margin-left: auto; margin-right: auto; margin-bottom:1em; width: 50%;">

The text file contains temperature values for a range of weather stations.
Each row is one measurement in the format `<string: station name>;<double: measurement>`, with the measurement value having exactly one fractional digit.
The following shows ten rows as an example:

```
Hamburg;12.0
Bulawayo;8.9
Palembang;38.8
St. John's;15.2
Cracow;12.6
Bridgetown;26.9
Istanbul;6.2
Roseau;34.4
Conakry;31.2
Istanbul;23.0
```

The task is to write a Java program which reads the file, calculates the min, mean, and max temperature value per weather station, and emits the results on stdout like this
(i.e. sorted alphabetically by station name, and the result values per station in the format `<min>/<mean>/<max>`, rounded to one fractional digit):

```
{Abha=-23.0/18.0/59.2, Abidjan=-16.2/26.0/67.3, Abéché=-10.0/29.4/69.0, Accra=-10.1/26.4/66.4, Addis Ababa=-23.7/16.0/67.0, Adelaide=-27.8/17.3/58.5, ...}
```

## License

This code base is available under the Apache License, version 2.

## Code of Conduct

Be excellent to each other!
More than winning, the purpose of this challenge is to have fun and learn something new.
