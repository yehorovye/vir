module main

import os
import cli
import json

const vir_config_path = os.expand_tilde_to_home('~/.vir/config.json')

struct Config {
mut:
	registered_dirs []RegisteredDir
}

struct RegisteredDir {
	name          string
	absolute_path string
	description   string
}

fn root_execute(cmd cli.Command) ! {
	if cmd.args.len == 0 {
		return error('please provide a registered directory name')
	}

	name := cmd.args[0]

	dir := get_registered_dir(name)!
	println(dir.absolute_path)
}

fn main() {
	mut app := cli.Command{
		name:        'vir'
		description: 'vir'
		execute:     root_execute
		flags:       [
			// this flag is useless btw!!!
			cli.Flag{
				flag:        cli.FlagType.bool
				name:        'silent'
				description: 'omit stdout logs'
			},
		]
		commands:    [
			cli.Command{
				name:    'add_dir'
				flags:   [
					cli.Flag{
						flag:          cli.FlagType.string
						name:          'description'
						abbrev:        'd'
						description:   'dir description'
						required:      false
						default_value: ['no description']
					},
				]
				execute: fn (cmd cli.Command) ! {
					name := cmd.args[0] or { error('specify a name first') }
					path := cmd.args[1] or { error('specify a path') }

					desc := cmd.flags.get_string('description') or { return 'no description' }

					new_file := RegisteredDir{
						name:          name
						absolute_path: path
						description:   desc
					}

					save_to_config(new_file) or {}
					println('saved dir bby')
					return
				}
			},
		]
	}

	app.setup()
	app.parse(os.args)
}

fn save_to_config(new_dir RegisteredDir) ! {
	mut config := load_config()!

	config.registered_dirs.prepend(new_dir)

	write_config(config)!
}

fn get_registered_dir(name string) !RegisteredDir {
	config := load_config()!

	for dir in config.registered_dirs {
		if dir.name == name {
			return dir
		}
	}

	return error('bitch i couldn\'t find the "${name}" dir smh')
}

fn get_all_registered_dirs() ![]RegisteredDir {
	config := load_config()!
	return config.registered_dirs
}

fn load_config() !Config {
	ensure_config_exists()!

	raw := os.read_file(vir_config_path)!

	if raw.trim_space() == '' {
		return Config{}
	}

	return json.decode(Config, raw) or {
		return error('failed to decode the fucking config: ${err}')
	}
}

fn write_config(config Config) ! {
	encoded := json.encode(config)
	os.write_file(vir_config_path, encoded)!
}

fn ensure_config_exists() ! {
	if os.exists(vir_config_path) {
		return
	}

	os.mkdir_all(os.dir(vir_config_path))!
	default_config := json.encode(Config{})
	os.write_file(vir_config_path, default_config)!
}
