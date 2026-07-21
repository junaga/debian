import importlib.util
import os
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


SOURCE = Path(__file__).parents[1] / "keycast.py"
SPEC = importlib.util.spec_from_file_location("keycast", SOURCE)
keycast = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(keycast)


class GridGeometryTest(unittest.TestCase):
    def setUp(self):
        bounds = keycast.Rect(0, 0, 1920, 1080)
        self.monitor = keycast.Monitor(0, "HDMI-A-1", bounds, bounds, True)
        self.geometry = keycast.GridGeometry(columns=3, rows=5, margin=20)

    def test_generates_fifteen_unique_targets(self):
        targets = self.geometry.targets(self.monitor, (760, 96))

        self.assertEqual(len(targets), 15)
        self.assertEqual(len({target.rect for target in targets}), 15)
        self.assertEqual(targets[0].rect, keycast.Rect(20, 76, 760, 96))
        self.assertEqual(targets[-1].rect, keycast.Rect(1140, 908, 760, 96))

    def test_nearest_selects_bottom_center(self):
        rect = keycast.Rect(600, 900, 760, 96)

        target = self.geometry.nearest(rect, [self.monitor])

        self.assertEqual((target.column, target.row), (1, 4))
        self.assertEqual(target.rect, keycast.Rect(580, 908, 760, 96))

    def test_nearest_can_cross_monitor_boundaries(self):
        second_bounds = keycast.Rect(1920, 0, 1920, 1080)
        second = keycast.Monitor(1, "DP-2", second_bounds, second_bounds)
        rect = keycast.Rect(2050, 40, 760, 96)

        target = self.geometry.nearest(rect, [self.monitor, second])

        self.assertEqual(target.monitor.name, "DP-2")
        self.assertEqual((target.column, target.row), (0, 0))

    def test_targets_respect_workarea(self):
        monitor = keycast.Monitor(
            0,
            "reserved",
            keycast.Rect(0, 0, 1920, 1080),
            keycast.Rect(40, 30, 1840, 1010),
        )

        targets = self.geometry.targets(monitor, (760, 96))

        self.assertGreaterEqual(min(target.rect.x for target in targets), 60)
        self.assertGreaterEqual(min(target.rect.y for target in targets), 50)
        self.assertLessEqual(max(target.rect.x + target.rect.width for target in targets), 1860)
        self.assertLessEqual(max(target.rect.y + target.rect.height for target in targets), 1020)


class InputParsingTest(unittest.TestCase):
    def test_interaction_requires_meta_and_hover(self):
        self.assertFalse(keycast.interaction_active(False, False))
        self.assertFalse(keycast.interaction_active(True, False))
        self.assertFalse(keycast.interaction_active(False, True))
        self.assertTrue(keycast.interaction_active(True, True))
        self.assertTrue(keycast.interaction_active(False, False, dragging=True))

    def test_left_button_event(self):
        line = "event7 POINTER_BUTTON +3.41s BTN_LEFT (272) pressed, seat count: 1"

        match = keycast.LEFT_BUTTON_EVENT.search(line)

        self.assertIsNotNone(match)
        self.assertEqual(match.group(1), "pressed")

    def test_left_button_release_without_numeric_code(self):
        line = "POINTER_BUTTON BTN_LEFT released"

        match = keycast.LEFT_BUTTON_EVENT.search(line)

        self.assertIsNotNone(match)
        self.assertEqual(match.group(1), "released")


class StateStoreTest(unittest.TestCase):
    def test_round_trip_uses_logical_slot(self):
        bounds = keycast.Rect(0, 0, 1920, 1080)
        monitor = keycast.Monitor(0, "HDMI-A-1", bounds, bounds)
        geometry = keycast.GridGeometry(3, 5, 20)
        target = geometry.targets(monitor, (760, 96))[7]

        with tempfile.TemporaryDirectory() as directory, patch.dict(
            os.environ, {"XDG_STATE_HOME": directory}
        ):
            store = keycast.StateStore()
            store.save(target, geometry)

            self.assertEqual(
                store.load(),
                {
                    "monitor": "HDMI-A-1",
                    "column": target.column,
                    "row": target.row,
                    "grid": [3, 5],
                },
            )


if __name__ == "__main__":
    unittest.main()
