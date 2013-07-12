/*
 * Copyright (C) 2013 - Alejandro T. Colombini
 * 
 * This is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
 
[Compact]
public class Gui
{
	public Gtk.Window window;
	public Gtk.Builder builder;

	public Gtk.ToggleAction action;
	public Gtk.Widget options;
	public weak SList<Gtk.RadioButton> radio_group;

	public Gtk.UIManager manager;
	public Gtk.ActionGroup actions;
	public uint merge_id;

	public Gui (Gtk.Builder builder)
	{
		this.builder = builder;

		window = builder.get_object ("window") as Gtk.Window;
		action = builder.get_object ("activate-action") as Gtk.ToggleAction;
		options = builder.get_object ("options") as Gtk.Widget;
		radio_group =
			(builder.get_object ("a-option") as Gtk.RadioButton).get_group ();

		manager = new Gtk.UIManager ();
		manager.insert_action_group
			(builder.get_object ("actions") as Gtk.ActionGroup, 0);

		try
		{
			manager.add_ui_from_file ("gui.xml");
			window.add_accel_group (manager.get_accel_group ());

			var menubar = manager.get_widget ("/menubar") as Gtk.MenuBar;
			var toolbar = manager.get_widget ("/toolbar") as Gtk.Toolbar;
			var box = builder.get_object ("box") as Gtk.Box;
			box.pack_start (menubar, false);
			box.pack_start (toolbar, false);

			// Style modifications
			toolbar.get_style_context ().add_class
				(Gtk.STYLE_CLASS_PRIMARY_TOOLBAR);
		}
		catch (Error e)
		{
			error (e.message);
		}

		builder.connect_signals (this);
		window.show_all ();
	}

	private void set_active_gui (string name, bool activate)
	{
		if (activate)
			try
			{
				var builder = new Gtk.Builder ();
				string ui = name + ".xml";

				builder.add_from_file (name + ".glade");
				builder.connect_signals (this);

				this.actions = builder.get_object ("actions") as Gtk.ActionGroup;
				manager.insert_action_group (this.actions, -1);
				merge_id = manager.add_ui_from_file (ui);
			}
			catch (Error e)
			{
				error (e.message);
			}
		else
			manager.remove_ui (merge_id);

		manager.ensure_update ();
		window.show_all ();
	}

	// Callback for Gtk.ToggleAction::toggled (activate-action)
	[CCode (instance_pos = -1)]
	public void activate_options (Gtk.ToggleAction action)
	{
		var active = action.get_active ();

		foreach (Gtk.RadioButton radio in radio_group)
			if (radio.get_active ())
			{
				if (active)
					option_toggled (radio);
				else
				{
					// Unload the interface controlled by radio
					var label = radio.get_label ();
					set_active_gui (label, false);
					print("Unloaded '" + label + "' UI\n");
				}
			}

		options.set_sensitive (active);
		action.set_stock_id (active ? Gtk.Stock.ZOOM_OUT : Gtk.Stock.ZOOM_IN);
	}

	// Callback for Gtk.ToggleButton::toggled (radio buttons)
	[CCode (instance_pos = -1)]
	public void option_toggled (Gtk.ToggleButton button)
	{
		var label = button.get_label ();
		var active = button.get_active ();

		set_active_gui (label, active);

		if (active)
			print("Loaded '" + label + "' UI\n");
		else
			print("Unloaded '" + label + "' UI\n");
	}

	// Callback for Gtk.Action::activate (about-action)
	[CCode (instance_pos = -1)]
	public void cb_show_about (Gtk.Action action)
	{
		Gtk.show_about_dialog (window,
			"program-name", "GtkUIManager Test",
			"comments", "Written in Vala",
			"copyright", "Copyright © Alejandro T. Colombini",
			"license-type", Gtk.License.GPL_3_0);
	}

	// Callback for Gtk.Action::activate (a-action)
	[CCode (instance_pos = -1)]
	public void cb_a_action (Gtk.Action action)
	{
		print ("'a' action performed.\n");
	}

	// Callback for Gtk.Action::activate (b-action)
	[CCode (instance_pos = -1)]
	public void cb_b_action (Gtk.Action action)
	{
		print ("'b' action performed.\n");
	}

	// Callback for Gtk.Action::activate (c-action)
	[CCode (instance_pos = -1)]
	public void cb_c_action (Gtk.Action action)
	{
		print ("'c' action performed.\n");
	}
}

public static void main (string[] args)
{
	Gui gui;

	Gtk.init (ref args);
	var builder = new Gtk.Builder ();

	try
	{
		builder.add_from_file ("gui.glade");
		gui = new Gui (builder);
		gui.window.show_all ();
	}
	catch (Error e)
	{
		error (e.message);
	}

	Gtk.main ();
}

