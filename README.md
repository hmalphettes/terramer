# Terramer: Terraform + Mermaid markup

Extend the [terraform graph](https://www.terraform.io/docs/commands/graph.html) command to generate mermaid diagrams.

# State

Very early code. A lot more ideas than code really.

Excuse golang noob-ness: this is my excuse to re-learn golang inspired by the masters: https://github.com/hashicorp/terraform/.

Currently using terraform as a library following this code: https://github.com/johandry/platformer/blob/master/platformer.go
As we get to learn the terraform code better, we may end-up with a different mechanism to get into the customize the graph output command.

# License

Same than Terraform: Mozilla Public License V2

# Sample diagram

Install the mermaid markdown preview plugin for VS Code to see the rendered diagram: https://github.com/mjbvz/vscode-markdown-mermaid

![Network diagram example](https://cloud.githubusercontent.com/assets/2233628/7765488/f5ed19dc-007b-11e5-896e-ce7a51161a4b.PNG)

Source: https://github.com/knsv/mermaid/issues/161#issuecomment-104521770
```mermaid
graph LR; I --> IG((IG))
  subgraph publicnet
    IG --> ELB
    NAT
  end
  subgraph webnet
    ELB --> Web1
    ELB --> Web2
    Web1 --> elb2
    Web2 --> elb2
  end
  subgraph appnet
    subgraph C1
    subgraph C1cluster1
    elb2 --> C1Prod1Ins1
    elb2 --> C1Prod1InsN
  end
  subgraph C1cluster2
    elb2 --> C1Prod2Ins1
    elb2 --> C1Prod2InsN
  end
  subgraph C1cluster3
    elb2 --> C1Prod3Ins1
    elb2 --> C1Prod3InsN
  end
  end
  subgraph C2
    subgraph C2cluster1
    elb2 --> C2Prod1Ins1
    elb2 --> C2Prod1InsN
  end
  subgraph C2cluster2
    elb2 --> C2Prod2Ins1
    elb2 --> C2Prod2InsN
  end
  subgraph C2cluster3
    elb2 --> C2Prod3Ins1
    elb2 --> C2Prod3InsN
  end
  end
  end
  subgraph dbnet
    C1Prod1Ins1 --> RDS1
    C1Prod1InsN --> RDS1
    C1Prod2Ins1 --> RDS1
    C1Prod2InsN --> RDS1
    C1Prod3Ins1 --> RDS1
    C1Prod3InsN --> RDS1
    C2Prod1Ins1 --> RDS2
    C2Prod1InsN --> RDS2
    C2Prod2Ins1 --> RDS2
    C2Prod2InsN --> RDS2
    C2Prod3Ins1 --> RDS2
    C2Prod3InsN --> RDS2
end
```
