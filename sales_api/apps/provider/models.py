from django.db import models


class Provider(models.Model):
    name = models.CharField(max_length=100)
    ruc = models.CharField(max_length=20, unique=True)
    phone = models.CharField(max_length=20)

    def __str__(self):
        return f"{self.name} ({self.ruc})"