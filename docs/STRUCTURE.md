# The Book of Secret Knowledge - Repository Structure

This document provides an overview of the repository organization.

## Directory Tree

```
the-book-of-secret-knowledge/
├── README.md                           # Main documentation with links and resources
├── LICENSE.md                          # MIT License
├── .github/                           # GitHub configuration
│   └── CONTRIBUTING.md                # Contribution guidelines
├── static/                            # Static assets
│   └── img/                          # Images and graphics
├── shell-functions/                   # Collection of useful shell functions
│   ├── README.md                     # Shell functions documentation
│   ├── network-functions.sh          # Network utilities (DNS, port check, etc.)
│   ├── system-functions.sh           # System monitoring and management
│   ├── file-functions.sh             # File operations and search
│   ├── git-functions.sh              # Git workflow helpers
│   ├── docker-functions.sh           # Docker management utilities
│   └── security-functions.sh         # Security auditing functions
├── docs/                             # Additional documentation (future)
└── cheatsheets/                      # Quick reference guides (future)
```

## Repository Organization

### Main Components

1. **README.md** - The primary document containing:
   - CLI Tools
   - GUI Tools
   - Web Tools
   - Systems/Services
   - Networks
   - Containers/Orchestration
   - Manuals/Howtos/Tutorials
   - Inspiring Lists
   - Blogs/Podcasts/Videos
   - Hacking/Penetration Testing
   - Your daily knowledge and news
   - Other Cheat Sheets
   - Shell One-liners
   - Shell Tricks
   - Shell Functions

2. **shell-functions/** - Organized shell function library with 6 categories:
   - Network operations
   - System administration
   - File management
   - Git workflows
   - Docker operations
   - Security auditing

3. **docs/** - Reserved for future organized documentation

4. **cheatsheets/** - Reserved for future quick reference materials

## Usage

### Browsing the Repository

- Start with the main [README.md](../README.md) for links to tools and resources
- Visit [shell-functions/](../shell-functions/) for ready-to-use shell functions
- Check individual function files for specific use cases

### Using Shell Functions

```bash
# Source all functions at once
for file in shell-functions/*.sh; do
  source "$file"
done

# Or source specific categories
source shell-functions/network-functions.sh
source shell-functions/system-functions.sh
```

## Future Enhancements

Planned organizational improvements:

- [ ] Move shell one-liners to separate files in `shell-functions/`
- [ ] Create dedicated `cheatsheets/` directory with topic-specific guides
- [ ] Organize `docs/` with categorized tutorials and howtos
- [ ] Add automated testing for shell functions
- [ ] Create installation script for easy setup

## Contributing

Please see [.github/CONTRIBUTING.md](../.github/CONTRIBUTING.md) for contribution guidelines.

## License

MIT License - see [LICENSE.md](../LICENSE.md)
