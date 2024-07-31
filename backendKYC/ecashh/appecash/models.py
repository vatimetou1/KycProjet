from django.db import models

class Personne(models.Model):
    NNI = models.CharField(max_length=20, unique=True)
    numero_tel = models.CharField(max_length=15)
    date_naissance = models.DateField()
    img = models.ImageField(upload_to='person_images/')
    lieu_naissance_ar = models.CharField(max_length=100)
    lieu_naissance_fr = models.CharField(max_length=100)
    nationalite_iso = models.CharField(max_length=3)
    nom_famille_ar = models.CharField(max_length=100)
    nom_famille_fr = models.CharField(max_length=100)
    prenom_ar = models.CharField(max_length=100)
    prenom_fr = models.CharField(max_length=100)
    prenom_pere_ar = models.CharField(max_length=100)
    prenom_pere_fr = models.CharField(max_length=100)
    sexe_fr = models.CharField(max_length=1)

    def __str__(self):
        return self.prenom_fr + ' ' + self.nom_famille_fr

