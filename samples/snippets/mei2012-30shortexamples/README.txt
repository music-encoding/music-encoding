Short Examples of MEI with Graphic Music Notation Equivalents
Craig Stuart Sapp (graphical music notation)
Perry Roland (MEI encodings, version 1.9b -- immediate precursor to MEI 2010-05)

February 2010
================================================================

Description of files:

----------------------------------------------------------------------------

Main printable file:

30shortexamples-20100310b.pdf == PDF of all graphical notation examples and
	full listings of equivalent MEI encodings.

----------------------------------------------------------------------------

Each example is found in a separate directory, with similar files, such as
these files for the beam-break example:

	description.xml	  == Description of example as XML database.
	description.txt	  == Description of example in a text-based database.
	break.mei	  == MEI 2012 encoding of the graphical music.
	break.mus	  == Binary SCORE data file for example.
	break.txt	  == ASCII version of SCORE data file.
	break.ai	  == Adobe Illustrator file with graphical notation.
	break.pdf         == Final PDF version of graphical notation.
	break-300.png	  == graphical music at 300 dpi bitmap (for OMR).
	break.png	  == Smaller PNG suitable for web viewing.


Examples related to beam encoding:
   beam-break	
	Demonstration of how to break a beam down to the sixteenth-note
	level and how to indicate two triplet "3" marks on a beam.
	Beethoven piano sonata no. 5 in C minor, op. 10/1, mvmt. 2:
	Adagio molto.
   beam-grace
	Demonstration of how grace notes interact with <beam>
	elements.  The first subexample shows how to place a gracenote
	inside of a grouping of beamed regular notes.  The second
	subexample shows how beamed grace notes are represented within
	a group of regular notes.
   beam-secondary
	Demonstration of how to break secondary beams.
	The first subexample shows a beam without breaks.
	The second subexample shows a break for every three notes.
	The third subexample shows a break for every two notes.

Examples related to chords:
   chord-artic
	Demonstration of how to encode articulations on single notes
	and on chords.  There are 4 staccato marks in this example
	applied to 6 notes.
   chord-bidur
	Demonstration of how to encode notes in a chord which
	do not all have the same duration.  This example contains
	an arpeggiated chord containing two quarter notes and one
	half note.  The logical duration of the chord is a half-note.
	This example is taken from Mozart's piano sonata no. 6 in
	D major (K<sup>1</sup> 284 / K<sup>6</sup> 205b), mvmt. 3, 
	variation 4 (Alte Mozart-Ausgabe).
   chord-seconds
	Demonstration of how to encode chords with the same
	pitches, but with different arrangement of seconds
	along the stem. (not possible in MEI, so no encoding example).

Examples related to staff voicing:
   layer-lhrh
	Demonstration of how to encode a single line of music which is
	displayed in multiple orthographic layers, but a single perceptual
	(analytic) layer. Stem directions in this example suggests which
	hand should play the notes.  Beethoven piano sonata no. 2 in A
	major, op. 2, no. 2, mvmt. 4: Rondo grazioso.
   layer-lhrh2
	Example of a layer which starts out in one staff and
	then changes to another in a measure.  Example from Beethoven's
	piano sonata no. 2 in A major, op. 2, no. 2, 
	mvmt. 4: Rondo: Grazioso.
   layer-lhrh3
	Demonstration of a melody spanning two staves, and
	layers on a single staff with stems going the same
	direction.  Example from Beethoven's piano sonata
	no. 4 in E-flat major, op. 7, mvmt. 4: Rondo: Poco
	allegretto grazioso.
   layer-lhrh4
	Demonstration of how to encode three musical lines on
	two staves when the middle line transfers to a different
	staff half-way through a measure.  Beethoven piano sonata
	no. 4 in E-flat major, op. 7, mvmt. 1: Allegro molto con brio.
   layer-lhrh5
	Demonstration of cross-staff layers.  Beethoven piano sonata
	no. 4 in E-flat major, op. 7, mvmt. 1: Allegro molto con brio.
   layer-x3staff
	Demonstration of an unusual interaction of layers across staves.
	Note in particular that the first treble clef on the bottom
	staff comes before the end of the bar so that a note from the
	stop staff can be written in treble clef.  Example from Joseph
	Haydn's keyboard sonata in G minor, Hoboken XVI:44 (Wiener Urtex
	no. 32), mvmt. 1.
   layer-xchord
	Demonstration of how to encode notes of chords which occur on
	two different staves. Example from Mozart's piano sonata no. 1
	in C major, K1 279, mvmt 2: Andante.
   layer-xstaff
	Demonstration of an unusual interaction of layers across staves.
	Note in particular that the first treble clef on the bottom
	staff comes before the end of the bar so that a note from the
	stop staff can be written in treble clef.  Example from Joseph
	Haydn's keyboard sonata in G minor, Hoboken XVI:44 (Wiener Urtex
	no. 32), mvmt. 1.
   layer-xtie
	Demonstration of how to encode ties which start and end
	in different layers.  This example is from Chopin's mauzrka
	in A minor Op. 17/4.

Examples related to lyrics:
   lyrics-syllab
	The vocal part contains the original text and a translation.
	In the third measure, the translation has two syllables while
	the original-language lyrics has one.  This is reflected in the
	music with a quarter note for the original lyrics and two eighth
	notes for the tranlated lyrics.  Similar double-stem notation 
	is used for multiple verses when the number of syllables varies
	between the verses.  Example from the piano reduction of Wagner's
	Rheingold.

Examples related to notes:
   note-caution
	Demonstration of how to indicate a cautionary accidental.
	The first subexample has an E-flat at the end of the
	second measure, but there is no accidental displayed,
	since it is contained in the key signature.
	The second subexample displays the flat, which is not
	technically required, but is provided for clarity to
	the performer.

Examples related to ornaments
   ornament-fturn
	Example of multiple finger numbers attached to an
	ornament (turn).  From Beethoven's piano sonata no. 8 
	in C minor, op. 13, mvmt. 2: Adagio cantabile.
   ornament-trill
	Demonstration of how to encode trills with and without
	wavy lines after them.  Also demonstration of how to
	encode accidental for upper neighboring tone on trill mark. 
	Example from Joseph Haydn's keyboard sonata in D major, 
	Hoboken XVI:33 (Wiener Urtex no. 34), mvmt. 1.
   ornament-turn
	Demonstration of how to encode turn ornaments.
	The example is from Beethoven's piano sonata no. 1 in F minor,
	op. 2, no. 1, mvmt. 2: Adagio.  The first turn is centered
	above the note it applies to.  The second turn in the next
	measure is centered *between* the note it is applied to and
	the following note in the layer.  Both of the example turns
	have accidentals underneath them; the first has a natural sign
	which means play the lower diatonic note as a natural (B-natural).
	The second has a sharp sign underneath it which means play 
	a sharped lower diatonic tone (F-sharp).  Turns can also have
	accidentals placed above them which indicate the chromatic
	alteration of the upper diatonic tone.
   ornament-turn2
	Demonstration of how to encode inter-note turn with
	a chromatic alteration of the lower and upper diatonic
	neighboring tones.  Beethoven piano sonata no. 2 in A major,
	op. 2, no. 2, mvmt. 1: Allegro vivace.

Examples related to rhythm:
   rhythm-fractup
	Demonstration of how to encode tuplet notes which
	contain rhythms which are not integer subdivisions 
	of the whole note.

Examples related to tuplets:
   tuplet-ambig
	Demonstration of how to encode rhythms when the visual
	display of note rhythms is ambiguous.
   tuplet-ambig2
	Demonstration of how to encode rhythms when the visual
	display of note rhythms is ambiguous.  This example is
	from Chopin's mazurka in A minor, Op. 17/4.  The notes
	in the top staff are quintuplet sixteenth notes, but they
	are displayed with a single beam rather than two beams.
	The tuplet notes are also cue-sized in the printed edition.
   tuplet-nested
	Demonstration of how to encode multiple levels of tuplets.
	This example simulates a written out ornament played as a 
	quintuplet 32nd notes within a triplet-eighth note pattern.

Example related to staff attributes:
   staff-keytime
	Demonstration of key and time signature changes, how they
	interact with sections, and and non-sequential performance sections.
   staff-layers
	Demonstration of staff layers, particularly of how invisible
	rests in thir measure are encoded.

Examples related to ties:
   tie-finger
	Demonstration of how to encode fingerd slurs.
	This example is from Beethoven piano sonata no. 23 in
	F minor, Op. 57, mvmt. 4: Presto.
   tie-finger2
	Demonstration of finger pedaling with durations of 
	notes explicitly written out.  Beethoven piano sonata
	no. 3 in C major, mvmt. 1: Allegro con brio.
   tie-xlayer
	Demonstration of how to encode ties which cross layers
	(initial to medial, and medial to terminal are in different
	layers).  Beethoven piano sonata no. 4 in E-flat major, op. 7,
	mvmt 1: Allegro molto brio.

----------------------------------------------------------------------------

Other files/directories:

Makefile	   == Makefile for creating bitmap images of music notation
bin/makepngfrompdf == Actual script to create png images from PDF files.
pdf		   == PDF files of graphical notation, individual and combined



