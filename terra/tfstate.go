package terra

import (
	"bytes"
	"fmt"
	"io/ioutil"

	"github.com/hashicorp/terraform/terraform"
)

// "github.com/terraform-providers/terraform-provider-aws/aws"
// "github.com/hashicorp/terraform/builtin/providers/aws"
// "github.com/hashicorp/terraform/builtin/providers/null"
// "github.com/hashicorp/terraform/builtin/providers/template"
// "github.com/hashicorp/terraform/config/module"

// Holds a terraform state and its source.
type Tfstate struct {
	Path  string
	State *terraform.State
}

// ReadStateFile will load the Terraform state from a file and assign it to the
// Platformer state. If the file is empty or fail to read it, and the current
// state is nil, it will assign a new empty state
func (t *Tfstate) Load(filename string) error {
	state, err := ioutil.ReadFile(filename)
	if err != nil {
		t.State = terraform.NewState()
		return nil
	}
	if len(state) > 0 {
		buf := bytes.NewBuffer(state)
		tfState, err := terraform.ReadState(buf)
		if err != nil {
			return nil
		}
		t.State = tfState
	} else {
		// State() will create a new empty state if it's nil
		t.State = terraform.NewState()
	}
	return nil
}

// state is nil, it will assign a new empty state
func (t *Tfstate) Traverse() error {
	for i := 0; i < len(t.State.Modules); i++ {
		moduleState := t.State.Modules[i]
		for k, v := range moduleState.Resources {
			fmt.Printf("key[%s] value[%s]\n", k, v.Type)
		}
	}
	return nil
}
