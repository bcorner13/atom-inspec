# Atom INSpec Runner Package

[![GitHub release](https://img.shields.io/github/release/qubyte/rubidium.svg)](https://github.com/bcorner13/atom-inspec)

Add ability to run inspec and see the output without leaving Atom.

HotKeys:

- __Ctrl+Alt+T__ - executes all specs the current file
- __Ctrl+Alt+X__ - executes only the spec on the line the cursor's at
- __Ctrl+Alt+E__ - re-executes the last executed spec

![Screenshot](http://cl.ly/image/2G2B3M2g3l3k/stats_collector_spec.rb%20-%20-Users-fcoury-Projects-crm_bliss.png)

## Configuration

By default this package will run `inspec` as the command.

You can set the default command by either accessing the Settings page (Cmd+,)
and changing the command option like below:

![Configuration Screenshot](http://f.cl.ly/items/2k1C0E0e1l2Z3m1l3e1R/Settings%20-%20-Users-fcoury-Projects-crm_bliss.jpg)

Or by opening your configuration file (clicking __Atom__ > __Open Your Config__)
and adding or changing the following snippet:

    'inspec':
      'command': 'bundle exec inspec'
