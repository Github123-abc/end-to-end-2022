resource "aws_key_pair" "master" {
  key_name   = "master"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC52b9Gvr4ByeA1TA/MDVr3T2LK1K+Vf9i0oFFo/FmjlMhImsqOZmJ+Kxbv5LFXN7Ce3sQ+Z775qsbMqViCh2jSW7kFs3TqYj9/KtZLRPnALhwQcxFEpLHEp+EtxfPnVZqthCcXmpEv5pwzNZIpJwXWiYMrogNqaCr+s/0ILS1ezLO6hKnizenrvkZg+iEgAWNfTv+mCCxTX7hJxcjH/dUP0GtED4IOPKks1TAtK9pqeJiuXCsZZJJys3dnY2HriL/vO4jJjTMjCscC8mwVvEF3A60l7JLszpF0ZGIS/iuQmn0EpslZmheEy4jl5/WFM1nDaBi/PYT0Tl8l7cv48XXT root@hemanth143"
  #   public_key = file(id_rsa.pub)
}