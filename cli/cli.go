package cli

import (
	"fmt"

	"github.com/hmalphettes/terramer/terra"
	"github.com/urfave/cli"
)

// FlagsStruct - holds command line args
type FlagsStruct struct {
	LogLevel string
}

var (
	cmds  []cli.Command
	flags []cli.Flag
)

func init() {
	cmds = []cli.Command{
		{
			Name:     "load",
			Aliases:  []string{"read"},
			Usage:    "load terraform.tfstate",
			Action:   load,
			Category: "Reading",
		},
	}
	flags = []cli.Flag{
		cli.StringFlag{
			Name:  "verbose, v",
			Usage: "Enable the logs",
			Value: "",
		},
	}
}

// StartCLI - gathers command line args
func StartCLI(cliFlags *FlagsStruct, args []string) error {
	app := cli.NewApp()
	app.Name = "Terramer"
	app.Usage = "terramer load vpc.tfstate app.tfstate"
	app.Description = "Terraform + mermaid: generate mermaid markup to visualize tfstate files"
	app.Version = "0.0.0.0"
	app.HideVersion = true
	app.Author = "Hugues Malphettes"
	app.Email = "hmalphettes at gmail.com"
	app.Commands = cmds
	app.Flags = flags
	app.Action = noArgs
	return app.Run(args)
}
func noArgs(c *cli.Context) error {
	cli.ShowAppHelp(c)
	return cli.NewExitError("no commands provided", 2)
}
func load(c *cli.Context) error {
	if !c.Args().Present() {
		cli.ShowSubcommandHelp(c)
		return cli.NewExitError("no arguments for subcommand", 3)
	}
	t := c.Args().First()
	fmt.Println("loading", t)

	var tfstate terra.Tfstate
	tfstate.Load(t)

	fmt.Printf("terraform_version %s\n", tfstate.State.TFVersion)
	fmt.Printf("aha %s\n", tfstate.Traverse())
	return nil
}
