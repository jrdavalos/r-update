# avant
tmp <- installed.packages(fields = c("GithubUsername", "GithubRepo"))
installedpkgs <- as.data.frame(tmp[is.na(tmp[,"Priority"]),
                                   c("Package", "Priority", "GithubUsername", "GithubRepo")],
                               row.names = 1)
save(installedpkgs, file = "installed_old.rda")

# après
load("installed_old.rda")
tmp <- installed.packages()
installedpkgs.new <- as.vector(tmp[is.na(tmp[,"Priority"]), 1])
missing <- installedpkgs[!installedpkgs$Package %in% installedpkgs.new,]
install.packages(missing$Package[is.na(missing$GithubRepo)])
if (any(!is.na(missing$GithubRepo))) {
  if (!"devtools" %in% installedpkgs$Package) {
    install.packages("devtools")
  }
  git <- missing$Package[!is.na(missing$GithubRepo)]
  repo <- paste0(missing$GithubUsername, "/", missing$GithubRepo)
  lapply(repo, function(x) {
    install_github(repo = x)
  })
}

# si besoin
update.packages()

# pour les repos Github (non finalisé)
update_github <- function() {
  pkgs <- installed.packages(fields = "RemoteType")
  github_pkgs <- pkgs[pkgs[, "RemoteType"] %in% "github", "Package"]
  
  print(github_pkgs)
  lapply(github_pkgs, function(pac) {
    message("Updating ", pac, " from GitHub...")
    
    repo = packageDescription(pac, fields = "GithubRepo")
    username = packageDescription(pac, fields = "GithubUsername")
    
    install_github(repo = paste0(username, "/", repo))
  })
}

