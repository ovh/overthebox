from setuptools import setup

setup(name='swconfig_otb',
      version='0.1',
      description='A module to manage OTB switches',
      author='Martin Wetterwald',
      author_email='martin.wetterwald@corp.ovh.com',
      license='MIT',
      install_requires=[
          'pyserial',
      ],
      packages=['swconfig_otb'],
      test_suite='tests',
      zip_safe=False)
