"""
Test custom Django management commands.
"""
from unittest.mock import patch

from psycopg2 import OperationalError as Psycopg2Error 

from django.core.management import call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase

@patch('core.management.commands.wait_for_db.Command.check') # Using the @patch decorator to mock the check method of the wait_for_db command. This decorator is applied to the entire test case class (CommandTest), and it ensures that any call to the check method will be replaced with a mock object. This allows you to control the behavior of the check method during the test.
class CommandTest(SimpleTestCase): #Defining a test case class named CommandTest that inherits from SimpleTestCase. This class will contain test methods for the wait_for_db command.
    """Test commands."""

    def test_wait_for_db_ready(self, patched_check): #Defining a test method named test_wait_for_db_ready that takes self and patched_check as parameters. patched_check is the mock object created by the @patch decorator.
        """Test waiting for Database if database is ready."""
        patched_check.return_value = True # Setting up the behavior of the check method mock. In this case, the mock is configured to return True, which simulates the situation where the database is ready.
        
        call_command('wait_for_db') # Calling the wait_for_db command using Django's call_command function. This simulates running the command.

        patched_check.assert_called_once_with(databases=['default']) #Asserting that the check method mock was called exactly once with the specified parameters (database=['default']). This ensures that the check method was called during the execution of the wait_for_db command.
    
    @patch('time.sleep') #This line uses the @patch decorator to mock the time.sleep function. The mock object is named patched_sleep.
    def test_wait_for_db_delay(self, patched_sleep, patched_check):
        """Test waiting for database when getting Operatinal Error"""

        patched_check.side_effect=[Psycopg2Error] * 2 + \
            [OperationalError] * 3 + [True]                    #This line configures the side_effect of the mocked check method. It specifies a sequence of side effects that the mock should exhibit when called.In this case we dont want to return a value (True for example), we want to raise an exception, that would be raised if the DB wasn't ready, by using side effect. The frist two times we called the mocked method we want to raise the psycopg2 error, then the next 3 times we raise operational error. The sixth time will return true.
        
        call_command('wait_for_db') #call_command('wait_for_db'): Invokes the wait_for_db command. During this call, the check method is invoked, and the specified side effects are triggered.

        self.assertEqual(patched_check.call_count, 6) # Asserts that the check method was called exactly six times. This checks that the wait_for_db command attempted to check the database status six times as specified by the side effects. 
        patched_check.assert_called_with(databases=['default']) #Asserts that the check method was called at least once with the specified parameters (database=['default']). This ensures that the wait_for_db command made at least one attempt to check the database status.