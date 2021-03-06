from django.conf.urls import patterns, include, url

from explorer import service
from helloWorld import views as helloWorld
from sourceLinks import views as sourceLinks
from termResources import views as termResources
from termResourcesCode import views as termResourcesCode
from analyzeSubmission import views as analyzeSubmission
from triggerCloneCreation import views as triggerCloneCreation
from cloneDiffer import views as cloneDiffer
from featureNameDetection import views as featureNameDetection
from worker_ui import views as workerViews
# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'services_temp.views.home', name='home'),
    # url(r'^services_temp/', include('services_temp.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),

    (r'^discovery/(?P<namespace>[^/]+)/(?P<member>[^/]+)(/(?P<path>.*))?/(?P<file>.*\.[^/]+)/(?P<fragment>.+)/?$', service.serveFileFragment),
    (r'^discovery/(?P<namespace>[^/]+)/(?P<member>[^/]+)(/(?P<path>.*))?/(?P<file>.*\.[^/]+)/?$', service.serveMemberFile),
    (r'^discovery/(?P<namespace>[^/]+)/(?P<member>[^/]+)/(?P<path>.+)/?$', service.serveMemberPath),
    (r'^discovery/(?P<namespace>[^/]+)/(?P<member>[^/]+)/?$', service.serveNamespaceMember),
    (r'^discovery/(?P<namespace>[^/]+)/?$', service.serveNamespace),
    (r'^discovery/?$', service.serveAllNamespaces ),


    (r'^hello$', helloWorld.hello),
    (r'^triggerCloneCreation$', triggerCloneCreation.trigger),
    (r'^featureNameDetection$', featureNameDetection.detect),
    (r'^diffClone$', cloneDiffer.diff),

    (r'^sourceLinks/(?P<name>.+)\.(?P<format>.+)$', sourceLinks.serveLink),

    ('^termResources/(?P<term>.+)/(?P<resource>.+)\.(?P<format>.+)$', termResources.serveTerm),
    ('^termResources/(?P<term>.+)\.(?P<format>.+)$', termResources.serveTerm),
    ('^termResources\.(?P<format>.+)$', termResources.serveResourceNames),
    ('^termResourcesCode/(?P<term>.+)/(?P<resName>.+)/(?P<cat>.+)/(?P<resIndex>.+)/(?P<codeIndex>.+)\.(?P<format>.+)$', termResourcesCode.serveCode),

    ('^analyzeSubmission$', analyzeSubmission.analyze),
    ('^worker$', workerViews.index),
)
