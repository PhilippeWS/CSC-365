DROP TABLE IF EXISTS Instruments;
DROP TABLE IF EXISTS Performance;
DROP TABLE IF EXISTS Tracklists;
DROP TABLE IF EXISTS Vocals;
DROP TABLE IF EXISTS Albums;
DROP TABLE IF EXISTS Band;
DROP TABLE IF EXISTS Songs;


CREATE Table Albums(
    AId INTEGER PRIMARY KEY,
    Title VARCHAR(37) NOT NULL,
    Year INTEGER NOT NULL,
    Label VARCHAR(32) NOT NULL,
    `Type` VARCHAR(6) NOT NULL
);

CREATE Table Songs(
    SongId INTEGER PRIMARY KEY,
    Title VARCHAR(32) NOT NULL
);


CREATE Table Band(
    Id INTEGER PRIMARY KEY,
    Firstname VARCHAR(32) NOT NULL,
    Lastname VARCHAR(32) NOT NULL
);

CREATE Table Instruments(
    SongId INTEGER,
    BandmateId INTEGER NOT NULL,
    Instrument VARCHAR(32) NOT NULL,
    
    PRIMARY KEY (SongId, BandmateId, Instrument),
    FOREIGN KEY InstrumentsSongId_SongsSongId (SongId) REFERENCES Songs(SongId),
    FOREIGN KEY InstrumentsBandmateId_BandId (BandmateId) REFERENCES Band(Id)
);

CREATE Table Performance(
    SongId INTEGER,
    Bandmate INTEGER NOT NULL,
    StagePosition VARCHAR(32) NOT NULL,
    
    PRIMARY KEY (SongId, Bandmate),
    FOREIGN KEY PerformanceSongId_SongsSongId (SongId) REFERENCES Songs(SongId),
    FOREIGN KEY PerformanceBandmate_BandId (Bandmate) REFERENCES Band(Id)
);


CREATE Table Tracklists(
    AlbumId INTEGER,
    Position INTEGER NOT NULL,
    SongId INTEGER NOT NULL,
    
    PRIMARY KEY (AlbumId, Position),
    FOREIGN KEY TracklistsAlbumId_AlbumsAId (AlbumId) REFERENCES Albums(AId),
    FOREIGN KEY TracklistsSongId_SongsSongId (SongId) REFERENCES Songs(SongId)
);

CREATE Table Vocals(
    SongId INTEGER,
    Bandmate INTEGER NOT NULL,
    `Type` VARCHAR(32) NOT NULL,
    
    PRIMARY KEY (SongId, Bandmate, `Type`),
    FOREIGN KEY VocalsSongId_SongsSongId (SongId) REFERENCES Songs(SongId),
    FOREIGN KEY VocalsBandmate_BandId (Bandmate) REFERENCES Band(Id)
);
