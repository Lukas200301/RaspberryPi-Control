package main

import (
	"net"
	"regexp"
	"strings"
)

// The agent runs as root, so every value that ends up as a program argument
// is checked first. Values must never start with "-", or the program would
// read them as an option.

var (
	hostnamePattern = regexp.MustCompile(`^[A-Za-z0-9]([A-Za-z0-9-]{0,62}[A-Za-z0-9])?(\.[A-Za-z0-9]([A-Za-z0-9-]{0,62}[A-Za-z0-9])?)*\.?$`)
	// Debian package names, optionally with ":arch" or "=version"
	packagePattern = regexp.MustCompile(`^[a-z0-9][a-z0-9+.-]*(:[a-z0-9-]+)?(=[A-Za-z0-9.+~:-]+)?$`)
	unitPattern    = regexp.MustCompile(`^[A-Za-z0-9@_.:\\-]+$`)
)

// validHost accepts IP addresses and DNS names
func validHost(h string) bool {
	if h == "" || len(h) > 253 {
		return false
	}
	if net.ParseIP(h) != nil {
		return true
	}
	return hostnamePattern.MatchString(h)
}

func validPackageName(name string) bool {
	return len(name) <= 200 && packagePattern.MatchString(name)
}

func validUnitName(name string) bool {
	return name != "" && len(name) <= 256 && !strings.HasPrefix(name, "-") && unitPattern.MatchString(name)
}

// validSearchTerm allows free text for `apt-cache search` but no options
func validSearchTerm(term string) bool {
	return len(term) <= 100 && !strings.HasPrefix(strings.TrimSpace(term), "-") && !strings.ContainsAny(term, "\x00\n")
}
