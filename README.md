# covid-vaccine-slot-notifier
- Periodically checks and notifies about the available slot for Covid Vaccination from CoWIN Portal at a given date for a given area. 
- Uses Open APIs to check the available slots. Visit [here](https://apisetu.gov.in/public/marketplace/api/cowin) for more information on Open APIs.
- Supports only Mac OS as of now. Support for other OS may come in near future.
- Uses Mac OS notification to notify about the available slot.
- Advantage of Mac OS notification over notification through email is it very quick and instant. Notification over email may take more time as it involves network calls.

# Installation

```
git clone https://github.com/sagar-jadhav/covid-vaccine-slot-notifier.git
```

# Usage

```
cd <Path to covid-vaccine-slot-notifier repo>
```

```
sh vaccine-notifier.sh
```

# Demo

![Demo](https://raw.githubusercontent.com/sagar-jadhav/covid-vaccine-slot-notifier/master/demo.gif)

# Contributing
We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
