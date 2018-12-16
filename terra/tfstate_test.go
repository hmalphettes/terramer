package terra

import (
	"path/filepath"
	"testing"
)

func TestLoad(t *testing.T) {
	tfstatePath := filepath.Join("testdata", "bucket.tfstate")
	var tfstate Tfstate
	tfstate.Load(tfstatePath)
	actual := tfstate.State.Version
	expected := 3 // it is always 3 a terraform will upgrade the state
	if actual != expected {
		t.Fatalf("bad: %d but expected %d", actual, expected)
	}
}
