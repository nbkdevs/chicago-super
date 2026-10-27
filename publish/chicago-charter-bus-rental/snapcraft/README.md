# Snapcraft

Build and publish **locally** (no CI required):

```bash
cd snap
chmod +x info.sh
snapcraft pack
snapcraft upload --release=stable chicago-charter-bus-rental_*.snap
```

Homepage: [Chicago Charter Bus Rental](https://chicagosupercoachbus.com/)
