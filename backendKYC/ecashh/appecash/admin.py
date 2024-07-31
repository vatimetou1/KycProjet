from django.contrib import admin
from .models import Personne

class PersonneAdmin(admin.ModelAdmin):
    list_display = [field.name for field in Personne._meta.fields if field.name != "id"]  # Affiche tous les champs sauf 'id'
    search_fields = ['NNI', 'prenom_fr', 'nom_famille_fr']  # Champs de recherche

admin.site.register(Personne, PersonneAdmin)
