from qgis.PyQt.QtCore import QCoreApplication
from qgis.core import (QgsProcessing,
                       QgsProcessingAlgorithm,
                       QgsProcessingParameterFile,
                       QgsProcessingParameterString,
                       QgsProcessingOutputMultipleLayers)
import os

class GetFileListAlgorithm(QgsProcessingAlgorithm):
    # Definition der Konstanten für die Parameter-Namen
    INPUT_FOLDER = 'INPUT_FOLDER'
    EXTENSION = 'EXTENSION'
    OUTPUT = 'OUTPUT'

    def tr(self, string):
        return QCoreApplication.translate('Processing', string)

    def createInstance(self):
        return GetFileListAlgorithm()

    def name(self):
        return 'getfilelistfromfolder'

    def displayName(self):
        return self.tr('GetLayerFormPath')

    def group(self):
        return self.tr('Eigene Skripte')

    def groupId(self):
        return 'customscripts'

    def initAlgorithm(self, config=None):
        # WICHTIG: QgsProcessingParameterFile mit behavior=1 für Ordner
        self.addParameter(
            QgsProcessingParameterFile(
                self.INPUT_FOLDER,
                self.tr('Wähle den Quellordner'),
                behavior=QgsProcessingParameterFile.Folder
            )
        )

        self.addParameter(
            QgsProcessingParameterString(
                self.EXTENSION,
                self.tr('Dateiendung (z.B. .tif oder .shp)'),
                defaultValue='.tif'
            )
        )
        
        self.addOutput(QgsProcessingOutputMultipleLayers(
            self.OUTPUT, 'Gefundene Dateien'))

    def processAlgorithm(self, parameters, context, feedback):
        # Parameter abrufen
        folder = self.parameterAsFile(parameters, self.INPUT_FOLDER, context)
        ext = self.parameterAsString(parameters, self.EXTENSION, context)

        # Liste der Dateien erstellen (mit vollem Pfad)
        # normpath bereinigt Pfad-Trenner (/ vs \)
        file_list = [
            os.path.normpath(os.path.join(folder, f))
            for f in os.listdir(folder)
            if f.lower().endswith(ext.lower()) and os.path.isfile(os.path.join(folder, f))
        ]

        if not file_list:
            feedback.reportError(f'Keine Dateien mit der Endung {ext} gefunden!', fatalError=True)

        feedback.pushInfo(f'{len(file_list)} Dateien gefunden.')

        # Die Liste wird als Dictionary zurückgegeben
        return {self.OUTPUT: file_list}
