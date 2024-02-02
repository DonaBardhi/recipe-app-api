"""
Django command to wait for the database to be available.
"""
import time 

from psycopg2 import OperationalError as Psycopg2OpError

from django.db.utils import OperationalError
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    """Django command to wait for the database."""

    def handle(self, *args, **options):
        """Entrypoint for command. """
        self.stdout.write("Waiting for database...")
        db_up=False #Firstly we assume that the db is not ready.
        while db_up is False:
            try:
                self.check(databases=['default']) #If the database is not ready it will throw one of the errors that we specified above, the db_up will remain false. If the DB is ready, there will be no errors throwed and the db_up will equal true, the while loop will stop.
                db_up = True
            except (Psycopg2OpError, OperationalError):
                self.stdout.write("Database unavailabe, waiting 1 second...")
                time.sleep(1)
        
        self.stdout.write(self.style.SUCCESS('Database available!'))